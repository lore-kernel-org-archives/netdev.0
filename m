From: Andi Kleen <ak@suse.de>
Subject: [PATCH] Remove bogus #ifdef CONFIG_SYSCTL in TCP
Date: Tue, 12 Oct 2004 18:38:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041012163806.GA4223@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@davemloft.net
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Modular IPv6 needs these variables always exported, even when 
CONFIG_SYSCTL is not enabled.

Signed-off-by: Andi Kleen <ak@suse.de>

diff -u linux/net/ipv4/tcp_ipv4.c-o linux/net/ipv4/tcp_ipv4.c
--- linux/net/ipv4/tcp_ipv4.c-o	2004-09-30 10:35:53.000000000 +0200
+++ linux/net/ipv4/tcp_ipv4.c	2004-10-12 18:35:56.000000000 +0200
@@ -2656,8 +2656,7 @@
 EXPORT_SYMBOL(tcp_proc_register);
 EXPORT_SYMBOL(tcp_proc_unregister);
 #endif
-#ifdef CONFIG_SYSCTL
 EXPORT_SYMBOL(sysctl_local_port_range);
 EXPORT_SYMBOL(sysctl_max_syn_backlog);
 EXPORT_SYMBOL(sysctl_tcp_low_latency);
-#endif
+
