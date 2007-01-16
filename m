From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 31/59] sysctl: C99 convert the ctl_tables in arch/mips/au1000/common/power.c
Date: Tue, 16 Jan 2007 09:39:36 -0700
Message-ID: <11689656551180-git-send-email-ebiederm@xmission.com>
References: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>
Cc: <linux-kernel@vger.kernel.org>, <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, xfs-masters@oss.sgi.com, xfs@oss.sgi.com,
	linux-scsi@vger.kernel.org, James.Bottomley@SteelEye.com,
	minyard@acm.org, openipmi-developer@lists.sourceforge.net,
	<tony.luck@intel.com>, linux-mips@linux-mips.org,
	ralf@linux-mips.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux390@de.ibm.com,
	linux-390@vm.marist.edu, paulus@samba.org, linuxppc-dev@ozlabs.org,
	lethal@linux-sh.org, linuxsh-shmedia-dev@lists.sourceforge.net,
	<ak@suse.de>, vojtech@suse.cz, clemens@ladisch.de,
	a.zummo@towertech.it, rtc-linux@googlegroups.com,
	linux-parport@lists.infradead.org, andrea@suse.de,
	tim@cyberelk.net, philb@gnu.org, aharkes@cs.cmu.edu,
	coda@cs.cmu.edu, codalist@TELEMANN.coda.cs.cmu.edu,
	aia21@cantab.net, linux-ntfs-dev@lists.sourceforge.net,
	mark.fasheh@oracle.com, kurt.hackel@oracle.com,
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751315AbXAPQoD@vger.kernel.org>
To: "<Andrew Morton" <akpm@osdl.org>
In-Reply-To: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 arch/mips/au1000/common/power.c |   38 ++++++++++++++++++++++++++++++++------
 1 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/arch/mips/au1000/common/power.c b/arch/mips/au1000/common/power.c
index b531ab7..31256b8 100644
--- a/arch/mips/au1000/common/power.c
+++ b/arch/mips/au1000/common/power.c
@@ -419,15 +419,41 @@ static int pm_do_freq(ctl_table * ctl, int write, struct file *file,
 
 
 static struct ctl_table pm_table[] = {
-	{CTL_UNNUMBERED, "suspend", NULL, 0, 0600, NULL, &pm_do_suspend},
-	{CTL_UNNUMBERED, "sleep", NULL, 0, 0600, NULL, &pm_do_sleep},
-	{CTL_UNNUMBERED, "freq", NULL, 0, 0600, NULL, &pm_do_freq},
-	{0}
+	{
+		.ctl_name 	= CTL_UNNUMBERED,
+		.procname	= "suspend",
+		.data		= NULL,
+		.maxlen		= 0,
+		.mode		= 0600,
+		.proc_handler	= &pm_do_suspend
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "sleep",
+		.data		= NULL,
+		.maxlen		= 0,
+		.mode		= 0600,
+		.proc_handler	= &pm_do_sleep
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "freq",
+		.data		= NULL,
+		.maxlen		= 0,
+		.mode		= 0600,
+		.proc_handler	= &pm_do_freq
+	},
+	{}
 };
 
 static struct ctl_table pm_dir_table[] = {
-	{CTL_UNNUMBERED, "pm", NULL, 0, 0555, pm_table},
-	{0}
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "pm",
+		.mode		= 0555,
+		.child		= pm_table
+	},
+	{}
 };
 
 /*
-- 
1.4.4.1.g278f
