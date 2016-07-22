From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Slicoss fixes and improvements
Date: Fri, 22 Jul 2016 23:09:10 +0200
Message-ID: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
To: liodot@gmail.com,
	charrer@alacritech.com,
	gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Hi,

this patch series tries to get the slicoss driver code closer to a state in
which it is ready to be moved out of staging.

Patch 1 is a resend of patch I sent a week ago and handles an allocation
failure in slic_init_adapter().

Patch 2 fixes link state notification.

Patch 3 turns the mapping for the io area from cached to uncached.

Patch 4 remove the delay of tx queue start until a link is detected.

Patch 5 introduces register accessor functions that use register offsets.
This is in preparation to replace the register addressing by means of the
slic_regs struct with an addressing by means of offsets. This is one of the
tasks listed in the TODO file.

Patch 6 introduces a slic_flush_write() function and handles issues that
could result form pci write posting.

Patch 7 completes the task started with patch 5

Patch 8 improves the implementation around the shared memory chunk used for
isr, status and link. It removes the volatile specifier from the slic_shmem
structure which is also listed in the TODO file.

Patch 9 also addresses a TODO by merging the structures for statistics and 
thereby removing some unions.

The patches have been tested with an Alacritech SEN2104ET PCI-E (4 Port)
adapter.

Regards,
Lino


[PATCH 1/9] staging: slicoss: handle allocation failure in
[PATCH 2/9] staging: slicoss: notifiy network stack about change in
[PATCH 3/9] staging: slicoss: ensure mapping of io-memory is uncached
[PATCH 4/9] staging: slicoss: start tx queue when interface is
[PATCH 5/9] staging: slicoss: introduce register accessors that use
[PATCH 6/9] staging: slicoss: avoid PCI write posting
[PATCH 7/9] staging: slicoss: dont use a structure but offsets for
[PATCH 8/9] staging: slicoss: improve implementation concerning the
[PATCH 9/9] staging: slicoss: simplify struct for statistics
