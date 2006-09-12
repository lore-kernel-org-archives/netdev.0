From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] bcm43xx-softmac: update noise handling
Date: Tue, 12 Sep 2006 14:21:55 -0400
Message-ID: <20060912182150.GE7703@tuxdriver.com>
References: <4506F110.mailATA11P27W@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:38925 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1030323AbWILSW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 14:22:28 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <4506F110.mailATA11P27W@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 12, 2006 at 12:40:32PM -0500, Larry Finger wrote:
> John,
> 
> Please apply this patch to wireless-2.6. In addition, please let me
> know if you have any problems applying it. I'm sending this by a new
> method.
 
Larry,

That one worked great!  One last request: please put any "chit-chat"
or other text not appropriate for the permanent changelog _AFTER_ the
"---" line.  Otherwise, I have to edit it out by hand.  I reformatted
the text from this patch below as an example of what I mean.

Thanks!

John

======================================================================================

In bcm43xx-softmac, the bcm43xx_stats struct contains a variable that
is no longer used. In addition, two TODO entries related to noise
processing in bcm43xx_rx have been completed, and as unused one
is removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
John,

Please apply this patch to wireless-2.6. In addition, please let me
know if you have any problems applying it. I'm sending this by a new
method.

Larry
 
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -666,7 +666,6 @@ struct bcm43xx_noise_calculation {
 };
 
 struct bcm43xx_stats {
-	u8 link_quality;
 	u8 noise;
 	struct iw_statistics wstats;
 	/* Store the last TX/RX times here for updating the leds. */
-- 
John W. Linville
linville@tuxdriver.com
