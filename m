From: Karsten Keil <kkeil@suse.de>
Subject: Re: [PATCH] isdn compile fix (resend)
Date: Mon, 15 Oct 2007 18:02:02 +0200
Message-ID: <20071015160202.GA25812@pingi.kke.suse.de>
References: <20071015144456.GA959@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kkeil@suse.de, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:49132 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757609AbXJOQCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 12:02:06 -0400
Content-Disposition: inline
In-Reply-To: <20071015144456.GA959@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 15, 2007 at 06:44:56PM +0400, Denis V. Lunev wrote:
Compilation fix. The problem appears after
7c076d1de869256848dacb8de0050a3a390f95df by Karsten Keil <kkeil@suse.de>

Acked-by: Karsten Keil <kkeil@suse.de>
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

-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
