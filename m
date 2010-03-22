From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.34-rc2: Reported regressions from 2.6.33
Date: Mon, 22 Mar 2010 10:12:38 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1003221012270.18017@i5.linux-foundation.org>
References: <M9dVcHY7TxH.A.2GC.ZBopLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: DRI <dri-devel@lists.sourceforge.net>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Linux PM List <linux-pm@lists.linux-foundation.org>,
        Maciej Rutecki <maciej.rutecki@gmail.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>,
        Alex Villacis Lasso <avillaci@ceibo.fiec.espol.edu.ec>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <M9dVcHY7TxH.A.2GC.ZBopLB@chimera>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


On Sun, 21 Mar 2010, Rafael J. Wysocki wrote:
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=15495
> Subject		: Flood of SELinux denials on polkitd
> Submitter	: Alex Villacis Lasso <avillaci@ceibo.fiec.espol.edu.ec>
> Date		: 2010-03-09 16:47 (13 days old)

Fixed by commit 3836a03d978e68b0ae00d3589089343c998cd4ff ("anon_inodes: 
mark the anon inode private"), I'm pretty sure.

		Linus
