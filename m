From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] compile failure with out proc fs
Date: Fri, 25 Jul 2003 13:36:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030725133638.168de3c3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Resolve compile error when CONFIG_IP_MULTICAST && !CONFIG_PROC_FS

diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	Fri Jul 25 12:31:11 2003
+++ b/net/ipv4/ip_output.c	Fri Jul 25 12:31:11 2003
@@ -1313,7 +1313,7 @@
 	ip_rt_init();
 	inet_initpeers();
 
-#ifdef CONFIG_IP_MULTICAST
+#if defined(CONFIG_IP_MULTICAST) && defined(CONFIG_PROC_FS)
 	igmp_mc_proc_init();
 #endif
 }
