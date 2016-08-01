From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3 3/3] mac80211: mesh: fixed HT ies in beacon template
Date: Mon, 01 Aug 2016 12:03:42 +0200
Message-ID: <1470045822.3389.24.camel@sipsolutions.net>
References: <20160713200755.26839-1-yanivma@ti.com>
	 <40a34537-486e-a466-5a7e-e253f19d81c3@gmail.com>
	 (sfid-20160722_072626_919337_95556AEF)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Meirav Kama <meiravk@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Masashi Honma <masashi.honma@gmail.com>,
	Yaniv Machani <yanivma@ti.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <40a34537-486e-a466-5a7e-e253f19d81c3@gmail.com> (sfid-20160722_072626_919337_95556AEF)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-07-22 at 14:26 +0900, Masashi Honma wrote:
> On 2016年07月14日 05:07, Yaniv Machani wrote:
> > +
> > +	/* if channel width is 20MHz - configure HT capab
> > accordingly*/
> > +	if (sdata->vif.bss_conf.chandef.width ==
> > NL80211_CHAN_WIDTH_20) {
> > +		cap &= ~IEEE80211_HT_CAP_SUP_WIDTH_20_40;
> > +		cap &= ~IEEE80211_HT_CAP_DSSSCCK40;
> > +	}
> 
> I have tested this part of your patch and this works for me.
> 
> Previouly, "Supported Channel Width Set bit" in HT Capabilities
> element was 1 even though disable_ht40=1 existed in
> wpa_supplicant.conf. After appllication of patch, the bit was 0.
> 

But why is that behaviour *correct*? We still support 40 MHz bandwidth
things, we just don't use them if we disable HT40.

johannes
