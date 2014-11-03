From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH bluetooth-next] netdevice: add ieee802154_ptr to
 net_device
Date: Mon, 03 Nov 2014 12:20:24 -0500 (EST)
Message-ID: <20141103.122024.541066618529355652.davem@davemloft.net>
References: <1414907094-9623-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1414907094-9623-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Sun,  2 Nov 2014 06:44:54 +0100

> This patch adds an ieee802154_ptr to the net_device structure.
> Furthermore the 802.15.4 subsystem will introduce a nl802154 framework
> which is similar like the nl80211 framework and a wpan_dev structure.
> The wpan_dev structure will hold additional net_device attributes like
> address options which are 802.15.4 specific. In the upcoming nl802154
> implementation we will introduce a NL802154_FLAG_NEED_WPAN_DEV like
> NL80211_FLAG_NEED_WDEV. For this flag an ieee802154_ptr in net_device is
> needed. Additional we can access the wpan_dev attributes in upper layers
> like IEEE 802.15.4 6LoWPAN easily. Current solution is a complicated
> callback interface and getting these values over subif data structure
> in mac802154.
> 
> Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

No objections, and you can merge this via the bluetooth tree:

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
