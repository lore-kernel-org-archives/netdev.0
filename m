From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] igmp -- proc_net_fops_create
Date: Thu, 11 Sep 2003 15:42:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911154240.3306d6df.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


diff -Nru a/net/ipv4/igmp.c b/net/ipv4/igmp.c
--- a/net/ipv4/igmp.c	Thu Sep 11 15:36:06 2003
+++ b/net/ipv4/igmp.c	Thu Sep 11 15:36:06 2003
@@ -2430,15 +2430,8 @@
 
 int __init igmp_mc_proc_init(void)
 {
-	struct proc_dir_entry *p;
-
-	p = create_proc_entry("igmp", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &igmp_mc_seq_fops;
-
-	p = create_proc_entry("mcfilter", S_IRUGO, proc_net);
-	if (p)
-		p->proc_fops = &igmp_mcf_seq_fops;
+	proc_net_fops_create("igmp", S_IRUGO, &igmp_mc_seq_fops);
+	proc_net_fops_create("mcfilter", S_IRUGO, &igmp_mcf_seq_fops);
 	return 0;
 }
 #endif
