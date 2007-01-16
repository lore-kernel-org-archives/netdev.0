From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 12/59] sysctl: atalk remove unnecessary insert_at_head flag
Date: Tue, 16 Jan 2007 09:39:17 -0700
Message-ID: <11689656281139-git-send-email-ebiederm@xmission.com>
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
Return-path: <linux-mips-bounce@linux-mips.org>
To: "<Andrew Morton" <akpm@osdl.org>
In-Reply-To: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/appletalk/sysctl_net_atalk.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/appletalk/sysctl_net_atalk.c b/net/appletalk/sysctl_net_atalk.c
index 40b0af7..4f806b6 100644
--- a/net/appletalk/sysctl_net_atalk.c
+++ b/net/appletalk/sysctl_net_atalk.c
@@ -73,7 +73,7 @@ static struct ctl_table_header *atalk_table_header;
 
 void atalk_register_sysctl(void)
 {
-	atalk_table_header = register_sysctl_table(atalk_root_table, 1);
+	atalk_table_header = register_sysctl_table(atalk_root_table, 0);
 }
 
 void atalk_unregister_sysctl(void)
-- 
1.4.4.1.g278f
