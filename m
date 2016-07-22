From: Masashi Honma <masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 3/3] mac80211: mesh: fixed HT ies in beacon template
Date: Fri, 22 Jul 2016 14:26:21 +0900
Message-ID: <40a34537-486e-a466-5a7e-e253f19d81c3@gmail.com>
References: <20160713200755.26839-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Meirav Kama <meiravk-l0cyMroinI0@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160713200755.26839-1-yanivma-l0cyMroinI0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2016年07月14日 05:07, Yaniv Machani wrote:
> +
> +	/* if channel width is 20MHz - configure HT capab accordingly*/
> +	if (sdata->vif.bss_conf.chandef.width == NL80211_CHAN_WIDTH_20) {
> +		cap &= ~IEEE80211_HT_CAP_SUP_WIDTH_20_40;
> +		cap &= ~IEEE80211_HT_CAP_DSSSCCK40;
> +	}

I have tested this part of your patch and this works for me.

Previouly, "Supported Channel Width Set bit" in HT Capabilities element
was 1 even though disable_ht40=1 existed in wpa_supplicant.conf.
After appllication of patch, the bit was 0.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
