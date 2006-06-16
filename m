From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: enable shared key authentication
Date: Fri, 16 Jun 2006 22:18:57 +0200
Message-ID: <200606162218.58158.mb@bu3sch.de>
References: <20060616195022.E73CD8A3591@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:21472
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751513AbWFPUTx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 16:19:53 -0400
To: linville@tuxdriver.com
In-Reply-To: <20060616195022.E73CD8A3591@zog.reactivated.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 16 June 2006 21:50, Daniel Drake wrote:
> I recently patched softmac to enable shared key authentication. This small patch
> will enable crazy or unfortunate bcm43xx users to use this new capability.
> 
> Signed-off-by: Daniel Drake <dsd@gentoo.org>

Signed-off-by: Michael Buesch <mb@bu3sch.de>

> Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -3599,6 +3599,10 @@ static void bcm43xx_ieee80211_set_securi
>  		secinfo->encrypt = sec->encrypt;
>  		dprintk(KERN_INFO PFX "   .encrypt = %d\n", sec->encrypt);
>  	}
> +	if (sec->flags & SEC_AUTH_MODE) {
> +		secinfo->auth_mode = sec->auth_mode;
> +		dprintk(KERN_INFO PFX "   .auth_mode = %d\n", sec->auth_mode);
> +	}
>  	if (bcm->initialized && !bcm->ieee->host_encrypt) {
>  		if (secinfo->enabled) {
>  			/* upload WEP keys to hardware */
> 

-- 
Greetings Michael.
