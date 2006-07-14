From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] remove unused routines from d80211 version of bcm43xx
Date: Sat, 15 Jul 2006 01:02:30 +0200
Message-ID: <200607150102.30704.mb@bu3sch.de>
References: <44B806DA.5010809@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:62114
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030460AbWGNXAW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 19:00:22 -0400
To: John Linville <linville@tuxdriver.com>
In-Reply-To: <44B806DA.5010809@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 14 July 2006 23:04, you wrote:
> This patch removes some unused static inline routines from bcm43xx-d80211 version of bcm43xx_main.h.
> 
> Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

Signed-off-by: Michael Buesch <mb@bu3sch.de>

> ===========================================================
> 
> index e228833..04d8b91 100644
> --- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h
> +++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h
> @@ -112,30 +112,6 @@ int bcm43xx_channel_to_freq(struct bcm43
>      return bcm43xx_channel_to_freq_bg(channel);
>   }
> 
> -/* Lightweight function to check if a channel number is valid.
> - * Note that this does _NOT_ check for geographical restrictions!
> - */
> -static inline
> -int bcm43xx_is_valid_channel_a(u8 channel)
> -{
> -    return (channel >= IEEE80211_52GHZ_MIN_CHANNEL
> -           && channel <= IEEE80211_52GHZ_MAX_CHANNEL);
> -}
> -static inline
> -int bcm43xx_is_valid_channel_bg(u8 channel)
> -{
> -    return (channel >= IEEE80211_24GHZ_MIN_CHANNEL
> -           && channel <= IEEE80211_24GHZ_MAX_CHANNEL);
> -}
> -static inline
> -int bcm43xx_is_valid_channel(struct bcm43xx_private *bcm,
> -                  u8 channel)
> -{
> -    if (bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_A)
> -        return bcm43xx_is_valid_channel_a(channel);
> -    return bcm43xx_is_valid_channel_bg(channel);
> -}
> -
>   void bcm43xx_tsf_read(struct bcm43xx_private *bcm, u64 *tsf);
>   void bcm43xx_tsf_write(struct bcm43xx_private *bcm, u64 tsf);

-- 
Greetings Michael.
