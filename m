From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFC] Patch to add board revision to the WLAN chip_id printout
Date: Fri, 1 Sep 2006 21:00:16 +0200
Message-ID: <200609012100.16638.mb@bu3sch.de>
References: <44F85187.3010707@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stefano Brivio <st3@riseup.net>, netdev@vger.kernel.org,
	Broadcom Linux <bcm43xx-dev@lists.berlios.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:23256
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750869AbWIATG5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 15:06:57 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44F85187.3010707@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 01 September 2006 17:28, Larry Finger wrote:
> Michael,
> 
> This patch includes the board revision in the chip_id printk for the ssb version of bcm43xx-d80211 
> and is meant to be applied to wireless-dev. As we have seen, behavior of the chips can be dependent 
> on the rev level, thus a need to have it in the log.

Any specific example on this?
I mean, every revision in the chip (and bcm43xx has a _lot_) can
(and does) change behaviour. But I still think we shouldn't print them
all on initialization. ;)

> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> 
> Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> +++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
> @@ -3346,7 +3346,8 @@ static int bcm43xx_attach_board(struct b
>   	if (err)
>   		goto err_chipset_detach;
> 
> -	printk(KERN_INFO PFX "Broadcom %04X WLAN found\n", bcm->ssb.chip_id);
> +	printk(KERN_INFO PFX "Broadcom %04X WLAN, Revision %d found\n",
> +		bcm->ssb.chip_id, bcm->board_revision);
> 
>   	/* Attach all IO cores to the backplane. */
>   	coremask = 0;
> 

-- 
Greetings Michael.
