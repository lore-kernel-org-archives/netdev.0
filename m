From: "Art Haas" <ahaas@airmail.net>
Subject: PATCH: Add C99 initializers to ip_conntrack_standalone.c
Date: Fri, 20 Feb 2004 13:01:48 -0600
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040220190148.GA26386@artsapartment.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@redhat.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi.

Here's a patch that converts this file to use C99 initializers. The code
is much easier to read after the conversion, I believe. I have
recompiled the file with the changes successfully.

The patch is against the current BK.

Art Haas

P.S. - I'd sent this patch on the 18th, and it was bounced back to me on
the 20th, so I'm trying to send it again. Apologies if it appears twice.

===== net/ipv4/netfilter/ip_conntrack_standalone.c 1.25 vs edited =====
--- 1.25/net/ipv4/netfilter/ip_conntrack_standalone.c	Wed Jan 28 18:01:06 2004
+++ edited/net/ipv4/netfilter/ip_conntrack_standalone.c	Wed Feb 18 17:12:38 2004
@@ -299,66 +299,151 @@
 static struct ctl_table_header *ip_ct_sysctl_header;
 
 static ctl_table ip_ct_sysctl_table[] = {
-	{NET_IPV4_NF_CONNTRACK_MAX, "ip_conntrack_max",
-	 &ip_conntrack_max, sizeof(int), 0644, NULL,
-	 &proc_dointvec},
-	{NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_SYN_SENT, "ip_conntrack_tcp_timeout_syn_sent",
-	 &ip_ct_tcp_timeout_syn_sent, sizeof(unsigned int), 0644, NULL,
-	 &proc_dointvec_jiffies},
-	{NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_SYN_RECV, "ip_conntrack_tcp_timeout_syn_recv",
-	 &ip_ct_tcp_timeout_syn_recv, sizeof(unsigned int), 0644, NULL,
-	 &proc_dointvec_jiffies},
-	{NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_ESTABLISHED, "ip_conntrack_tcp_timeout_established",
-	 &ip_ct_tcp_timeout_established, sizeof(unsigned int), 0644, NULL,
-	 &proc_dointvec_jiffies},
-	{NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_FIN_WAIT, "ip_conntrack_tcp_timeout_fin_wait",
-	 &ip_ct_tcp_timeout_fin_wait, sizeof(unsigned int), 0644, NULL,
-	 &proc_dointvec_jiffies},
-	{NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_CLOSE_WAIT, "ip_conntrack_tcp_timeout_close_wait",
-	 &ip_ct_tcp_timeout_close_wait, sizeof(unsigned int), 0644, NULL,
-	 &proc_dointvec_jiffies},
-	{NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_LAST_ACK, "ip_conntrack_tcp_timeout_last_ack",
-	 &ip_ct_tcp_timeout_last_ack, sizeof(unsigned int), 0644, NULL,
-	 &proc_dointvec_jiffies},
-	{NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_TIME_WAIT, "ip_conntrack_tcp_timeout_time_wait",
-	 &ip_ct_tcp_timeout_time_wait, sizeof(unsigned int), 0644, NULL,
-	 &proc_dointvec_jiffies},
-	{NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_CLOSE, "ip_conntrack_tcp_timeout_close",
-	 &ip_ct_tcp_timeout_close, sizeof(unsigned int), 0644, NULL,
-	 &proc_dointvec_jiffies},
-	{NET_IPV4_NF_CONNTRACK_UDP_TIMEOUT, "ip_conntrack_udp_timeout",
-	 &ip_ct_udp_timeout, sizeof(unsigned int), 0644, NULL,
-	 &proc_dointvec_jiffies},
-	{NET_IPV4_NF_CONNTRACK_UDP_TIMEOUT_STREAM, "ip_conntrack_udp_timeout_stream",
-	 &ip_ct_udp_timeout_stream, sizeof(unsigned int), 0644, NULL,
-	 &proc_dointvec_jiffies},
-	{NET_IPV4_NF_CONNTRACK_ICMP_TIMEOUT, "ip_conntrack_icmp_timeout",
-	 &ip_ct_icmp_timeout, sizeof(unsigned int), 0644, NULL,
-	 &proc_dointvec_jiffies},
-	{NET_IPV4_NF_CONNTRACK_GENERIC_TIMEOUT, "ip_conntrack_generic_timeout",
-	 &ip_ct_generic_timeout, sizeof(unsigned int), 0644, NULL,
-	 &proc_dointvec_jiffies},
-	{0}
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_MAX,
+		.procname	= "ip_conntrack_max",
+		.data		= &ip_conntrack_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_SYN_SENT,
+		.procname	= "ip_conntrack_tcp_timeout_syn_sent",
+		.data		= &ip_ct_tcp_timeout_syn_sent,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_SYN_RECV,
+		.procname	= "ip_conntrack_tcp_timeout_syn_recv",
+		.data		= &ip_ct_tcp_timeout_syn_recv,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_ESTABLISHED,
+		.procname	= "ip_conntrack_tcp_timeout_established",
+		.data		= &ip_ct_tcp_timeout_established,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_FIN_WAIT,
+		.procname	= "ip_conntrack_tcp_timeout_fin_wait",
+		.data		= &ip_ct_tcp_timeout_fin_wait,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_CLOSE_WAIT,
+		.procname	= "ip_conntrack_tcp_timeout_close_wait",
+		.data		= &ip_ct_tcp_timeout_close_wait,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_LAST_ACK,
+		.procname	= "ip_conntrack_tcp_timeout_last_ack",
+		.data		= &ip_ct_tcp_timeout_last_ack,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_TIME_WAIT,
+		.procname	= "ip_conntrack_tcp_timeout_time_wait",
+		.data		= &ip_ct_tcp_timeout_time_wait,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_TIMEOUT_CLOSE,
+		.procname	= "ip_conntrack_tcp_timeout_close",
+		.data		= &ip_ct_tcp_timeout_close,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_UDP_TIMEOUT,
+		.procname	= "ip_conntrack_udp_timeout",
+		.data		= &ip_ct_udp_timeout,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_UDP_TIMEOUT_STREAM,
+		.procname	= "ip_conntrack_udp_timeout_stream",
+		.data		= &ip_ct_udp_timeout_stream,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_ICMP_TIMEOUT,
+		.procname	= "ip_conntrack_icmp_timeout",
+		.data		= &ip_ct_icmp_timeout,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{
+		.ctl_name	= NET_IPV4_NF_CONNTRACK_GENERIC_TIMEOUT,
+		.procname	= "ip_conntrack_generic_timeout",
+		.data		= &ip_ct_generic_timeout,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{ .ctl_name = 0 }
 };
 
 #define NET_IP_CONNTRACK_MAX 2089
 
 static ctl_table ip_ct_netfilter_table[] = {
-	{NET_IPV4_NETFILTER, "netfilter", NULL, 0, 0555, ip_ct_sysctl_table, 0, 0, 0, 0, 0},
-	{NET_IP_CONNTRACK_MAX, "ip_conntrack_max",
-	 &ip_conntrack_max, sizeof(int), 0644, NULL,
-	 &proc_dointvec},
-	{0}
+	{
+		.ctl_name	= NET_IPV4_NETFILTER,
+		.procname	= "netfilter",
+		.mode		= 0555,
+		.child		= ip_ct_sysctl_table,
+	},
+	{
+		.ctl_name	= NET_IP_CONNTRACK_MAX,
+		.procname	= "ip_conntrack_max",
+		.data		= &ip_conntrack_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
+	{ .ctl_name = 0 }
 };
 
 static ctl_table ip_ct_ipv4_table[] = {
-	{NET_IPV4, "ipv4", NULL, 0, 0555, ip_ct_netfilter_table, 0, 0, 0, 0, 0},
-	{0}
+	{
+		.ctl_name	= NET_IPV4,
+		.procname	= "ipv4",
+		.mode		= 0555,
+		.child		= ip_ct_netfilter_table,
+	},
+	{ .ctl_name = 0 }
 };
 
 static ctl_table ip_ct_net_table[] = {
-	{CTL_NET, "net", NULL, 0, 0555, ip_ct_ipv4_table, 0, 0, 0, 0, 0},
-	{0}
+	{
+		.ctl_name	= CTL_NET,
+		.procname	= "net",
+		.mode		= 0555, 
+		.child		= ip_ct_ipv4_table,
+	},
+	{ .ctl_name = 0 }
 };
 #endif
 static int init_or_cleanup(int init)
-- 
Man once surrendering his reason, has no remaining guard against absurdities
the most monstrous, and like a ship without rudder, is the sport of every wind.

-Thomas Jefferson to James Smith, 1822
