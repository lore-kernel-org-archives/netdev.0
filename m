From: Bob Copeland <me@bobcopeland.com>
Subject: Re: [PATCH 3/4] mac80211: mesh: fixed HT ies in beacon template
Date: Tue, 28 Jun 2016 10:06:26 -0400
Message-ID: <20160628140625.GC9984@localhost>
References: <20160628111307.8784-1-yanivma@ti.com>
 <20160628111307.8784-2-yanivma@ti.com>
 <20160628111307.8784-3-yanivma@ti.com>
 <20160628111307.8784-4-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S . Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Meirav Kama <meiravk@ti.com>
To: Yaniv Machani <yanivma@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160628111307.8784-4-yanivma@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 28, 2016 at 02:13:06PM +0300, Yaniv Machani wrote:
> From: Meirav Kama <meiravk@ti.com>
> 
> There are several values in HT info elements of mesh beacon (built by the
> mac80211) that are incorrect.

Would be good to enumerate the problems here.

> To fix them:
> 1. mac80211 will check configuration from cfg and will build accordingly.
> 2. changes made in mesh default values.

What is wrong with the defaults?

>  	sband = local->hw.wiphy->bands[band];
>  	if (!sband->ht_cap.ht_supported ||
> @@ -431,11 +433,40 @@ int mesh_add_ht_cap_ie(struct ieee80211_sub_if_data *sdata,
>  	    sdata->vif.bss_conf.chandef.width == NL80211_CHAN_WIDTH_10)
>  		return 0;
>  
> +    /* determine capability flags */
> +	cap = sband->ht_cap.cap;

There is some weird whitespace here (space instead of tabs for the
comment).

-- 
Bob Copeland %% http://bobcopeland.com/
