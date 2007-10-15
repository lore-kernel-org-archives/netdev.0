From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] isdn compile fix (resend)
Date: Mon, 15 Oct 2007 18:44:56 +0400
Message-ID: <20071015144456.GA959@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kkeil@suse.de, den@openvz.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:52026 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751464AbXJOOmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 10:42:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compilation fix. The problem appears after
7c076d1de869256848dacb8de0050a3a390f95df by Karsten Keil <kkeil@suse.de>

CC: Karsten Keil <kkeil@suse.de>
Signed-off-by: Denis V. Lunev <den@openvz.org>

--- ./drivers/isdn/i4l/isdn_net.c.isdn2	2007-10-15 13:55:24.000000000 +0400
+++ ./drivers/isdn/i4l/isdn_net.c	2007-10-15 18:19:11.000000000 +0400
@@ -2713,7 +2713,7 @@ isdn_net_setcfg(isdn_net_ioctl_cfg * cfg
 		case ISDN_NET_ENCAP_X25IFACE:
 #ifndef CONFIG_ISDN_X25
 			printk(KERN_WARNING "%s: isdn-x25 support not configured\n",
-			       p->local->name);
+			       p->dev->name);
 			return -EINVAL;
 #else
 			p->dev->type = ARPHRD_X25;	/* change ARP type */
