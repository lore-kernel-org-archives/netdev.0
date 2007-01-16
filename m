From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 10/59] sysctl: dccp remove unnecessary insert_at_head flag
Date: Tue, 16 Jan 2007 09:39:15 -0700
Message-ID: <1168965624939-git-send-email-ebiederm@xmission.com>
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
 net/dccp/sysctl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
index fdcfca3..3391631 100644
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -127,7 +127,7 @@ static struct ctl_table_header *dccp_table_header;
 
 int __init dccp_sysctl_init(void)
 {
-	dccp_table_header = register_sysctl_table(dccp_root_table, 1);
+	dccp_table_header = register_sysctl_table(dccp_root_table, 0);
 
 	return dccp_table_header != NULL ? 0 : -ENOMEM;
 }
-- 
1.4.4.1.g278f
