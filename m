From: Vojtech Pavlik <vojtech@suse.cz>
Subject: Re: ipw2100 wireless driver
Date: Wed, 14 Jul 2004 15:15:23 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040714131523.GA498@ucw.cz>
References: <20040714114135.GA25175@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, kernel list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S267377AbUGNNNk@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Content-Disposition: inline
In-Reply-To: <20040714114135.GA25175@elf.ucw.cz>
List-Id: netdev.vger.kernel.org

On Wed, Jul 14, 2004 at 01:41:35PM +0200, Pavel Machek wrote:
> Hi!
> 
> What is the status of ipw2100? Is there chance that it would be pushed
> into mainline?
> 
> I have few problems with that:
> 
> * it will not compile with gcc-2.95. Attached patch fixes one problem
> but more remain.

Wouldn't "struct sk_buff **fragments" be a more correct fix?

> --- ipw2100-ofic/ieee80211.h	2004-07-09 06:32:17.000000000 +0200
> +++ ipw2100-0.49/ieee80211.h	2004-07-14 13:18:50.000000000 +0200
> @@ -440,7 +440,7 @@
>  	u16 reserved;
>  	u16 frag_size;
>  	u16 payload_size;
> -	struct sk_buff *fragments[];
> +	struct sk_buff *fragments[1];
>  };
>  
>  extern struct ieee80211_txb *ieee80211_skb_to_txb(struct ieee80211_device *ieee, 
> 
> * it requires CONFIG_CRYPTO, but fails to force it in Kconfig.
> 
> 									Pavel
> -- 
> People were complaining that M$ turns users into beta-testers...
> ...jr ghea gurz vagb qrirybcref, naq gurl frrz gb yvxr vg gung jnl!
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

-- 
Vojtech Pavlik
SuSE Labs, SuSE CR
