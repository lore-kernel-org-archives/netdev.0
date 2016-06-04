From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/3] Some fixes got r8712u
Date: Fri,  3 Jun 2016 20:17:34 -0500
Message-ID: <1465003057-2590-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
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

While testing the patches that removed the semaphores from this driver,
kmemleak reported some leaked skbs. There were also some false positives.
I also found code that dereferenced a pointer before it was checked. All
of these conditions are fixed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (3):
  staging: r8712u: Check pointer before use
  staging: r8712u: Fix leak of skb
  staging: r8712u: Handle some false positives from kmemleak

 drivers/staging/rtl8712/recv_linux.c    |  1 -
 drivers/staging/rtl8712/rtl8712_recv.h  |  1 -
 drivers/staging/rtl8712/usb_ops_linux.c | 86 ++++++++++++++-------------------
 drivers/staging/rtl8712/xmit_linux.c    |  2 +
 4 files changed, 39 insertions(+), 51 deletions(-)

-- 
2.1.4
