From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] missing annotation in ipv6 addrconf
Date: Mon, 12 Jul 2004 15:04:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040712150444.0396b23e@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Missing __user annotation in simulated ioctl call.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-07-12 15:02:04 -07:00
+++ b/net/ipv6/addrconf.c	2004-07-12 15:02:04 -07:00
@@ -1544,7 +1544,7 @@
 		p.iph.ihl = 5;
 		p.iph.protocol = IPPROTO_IPV6;
 		p.iph.ttl = 64;
-		ifr.ifr_ifru.ifru_data = (void*)&p;
+		ifr.ifr_ifru.ifru_data = (void __user *)&p;
 
 		oldfs = get_fs(); set_fs(KERNEL_DS);
 		err = dev->do_ioctl(dev, &ifr, SIOCADDTUNNEL);
