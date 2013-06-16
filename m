From: Johannes Stezenbach <js@sig21.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Sun, 16 Jun 2013 20:42:20 +0200
Message-ID: <20130616184220.GA5469@sig21.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
 <20130613222411.GA5396@sig21.net>
 <1371162553.8335.28.camel@jlt4.sipsolutions.net>
 <20130614055346.GB6547@sig21.net>
 <1371320772.8319.2.camel@jlt4.sipsolutions.net>
 <1371327319.14174.1.camel@jlt4.sipsolutions.net>
 <20130616094930.GA5899@sig21.net>
 <1371381472.8546.1.camel@jlt4.sipsolutions.net>
 <20130616174834.GA5236@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:43699 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755133Ab3FPSmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jun 2013 14:42:24 -0400
Content-Disposition: inline
In-Reply-To: <20130616174834.GA5236@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 16, 2013 at 07:48:34PM +0200, Johannes Stezenbach wrote:
> 
> The last version which worked was in compat-wireless-3.6.8-1-snpc.tar.bz2
> from http://wireless.kernel.org/en/users/Download/stable#compat-wireless_3.6_stable_releases
> which I had compiled for linux-3.7.6.

I got it working with this change:

--- ./drivers/net/ethernet/atheros/alx/main.c.orig	2013-06-16 11:13:30.763491166 +0200
+++ ./drivers/net/ethernet/atheros/alx/main.c	2013-06-16 20:34:24.351045235 +0200
@@ -722,6 +722,7 @@ static int alx_init_sw(struct alx_priv *
 		      ALX_MAC_CTRL_TXFC_EN |
 		      7 << ALX_MAC_CTRL_PRMBLEN_SHIFT;
 
+	pdev->dev_flags |= PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG;
 	return err;
 }
 

The compat-wireless-3.6.8-1-snpc driver applied this
flag for AR8161 and AR8162 if I got it correctly.


Thanks
Johannes
