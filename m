From: Sean Neakums <sneakums@zork.net>
Subject: [PATCH] correct 'discvovery' typo
Date: Sun, 20 Jul 2003 22:20:26 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6ubrvo7v51.fsf@zork.zork.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Against 2.6.0-test1.


diff --exclude '*~' -urN T1/net/ipv4/ah4.c T1.edit/net/ipv4/ah4.c
--- T1/net/ipv4/ah4.c	2003-07-14 04:37:32.000000000 +0100
+++ T1.edit/net/ipv4/ah4.c	2003-07-20 22:11:23.000000000 +0100
@@ -232,7 +232,7 @@
 	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET);
 	if (!x)
 		return;
-	printk(KERN_DEBUG "pmtu discvovery on SA AH/%08x/%08x\n",
+	printk(KERN_DEBUG "pmtu discovery on SA AH/%08x/%08x\n",
 	       ntohl(ah->spi), ntohl(iph->daddr));
 	xfrm_state_put(x);
 }
diff --exclude '*~' -urN T1/net/ipv4/esp4.c T1.edit/net/ipv4/esp4.c
--- T1/net/ipv4/esp4.c	2003-07-14 04:34:43.000000000 +0100
+++ T1.edit/net/ipv4/esp4.c	2003-07-20 22:11:18.000000000 +0100
@@ -425,7 +425,7 @@
 	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET);
 	if (!x)
 		return;
-	printk(KERN_DEBUG "pmtu discvovery on SA ESP/%08x/%08x\n",
+	printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/%08x\n",
 	       ntohl(esph->spi), ntohl(iph->daddr));
 	xfrm_state_put(x);
 }
diff --exclude '*~' -urN T1/net/ipv4/ipcomp.c T1.edit/net/ipv4/ipcomp.c
--- T1/net/ipv4/ipcomp.c	2003-07-14 04:37:28.000000000 +0100
+++ T1.edit/net/ipv4/ipcomp.c	2003-07-20 22:11:21.000000000 +0100
@@ -256,7 +256,7 @@
 	                      spi, IPPROTO_COMP, AF_INET);
 	if (!x)
 		return;
-	printk(KERN_DEBUG "pmtu discvovery on SA IPCOMP/%08x/%u.%u.%u.%u\n",
+	printk(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/%u.%u.%u.%u\n",
 	       spi, NIPQUAD(iph->daddr));
 	xfrm_state_put(x);
 }
diff --exclude '*~' -urN T1/net/ipv6/ah6.c T1.edit/net/ipv6/ah6.c
--- T1/net/ipv6/ah6.c	2003-07-14 04:36:31.000000000 +0100
+++ T1.edit/net/ipv6/ah6.c	2003-07-20 22:11:30.000000000 +0100
@@ -364,7 +364,7 @@
 	if (!x)
 		return;
 
-	printk(KERN_DEBUG "pmtu discvovery on SA AH/%08x/"
+	printk(KERN_DEBUG "pmtu discovery on SA AH/%08x/"
 			"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
 	       ntohl(ah->spi), NIP6(iph->daddr));
 
diff --exclude '*~' -urN T1/net/ipv6/esp6.c T1.edit/net/ipv6/esp6.c
--- T1/net/ipv6/esp6.c	2003-07-14 04:35:16.000000000 +0100
+++ T1.edit/net/ipv6/esp6.c	2003-07-20 22:11:28.000000000 +0100
@@ -317,7 +317,7 @@
 	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, esph->spi, IPPROTO_ESP, AF_INET6);
 	if (!x)
 		return;
-	printk(KERN_DEBUG "pmtu discvovery on SA ESP/%08x/"
+	printk(KERN_DEBUG "pmtu discovery on SA ESP/%08x/"
 			"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n", 
 			ntohl(esph->spi), NIP6(iph->daddr));
 	xfrm_state_put(x);
diff --exclude '*~' -urN T1/net/ipv6/ipcomp6.c T1.edit/net/ipv6/ipcomp6.c
--- T1/net/ipv6/ipcomp6.c	2003-07-14 04:34:31.000000000 +0100
+++ T1.edit/net/ipv6/ipcomp6.c	2003-07-20 22:11:25.000000000 +0100
@@ -248,7 +248,7 @@
 	if (!x)
 		return;
 
-	printk(KERN_DEBUG "pmtu discvovery on SA IPCOMP/%08x/"
+	printk(KERN_DEBUG "pmtu discovery on SA IPCOMP/%08x/"
 			"%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
 			spi, NIP6(iph->daddr));
 	xfrm_state_put(x);
