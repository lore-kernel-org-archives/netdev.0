From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH bluetooth-next] netdevice: add ieee802154_ptr to net_device
Date: Mon, 3 Nov 2014 13:35:02 -0800
Message-ID: <F8A94B2C-4EFE-4867-A447-C98ED5142B3B@holtmann.org>
References: <1414907094-9623-1-git-send-email-alex.aring@gmail.com> <20141103.122024.541066618529355652.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141103.122024.541066618529355652.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alex,

>> This patch adds an ieee802154_ptr to the net_device structure.
>> Furthermore the 802.15.4 subsystem will introduce a nl802154 framework
>> which is similar like the nl80211 framework and a wpan_dev structure.
>> The wpan_dev structure will hold additional net_device attributes like
>> address options which are 802.15.4 specific. In the upcoming nl802154
>> implementation we will introduce a NL802154_FLAG_NEED_WPAN_DEV like
>> NL80211_FLAG_NEED_WDEV. For this flag an ieee802154_ptr in net_device is
>> needed. Additional we can access the wpan_dev attributes in upper layers
>> like IEEE 802.15.4 6LoWPAN easily. Current solution is a complicated
>> callback interface and getting these values over subif data structure
>> in mac802154.
>> 
>> Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> No objections, and you can merge this via the bluetooth tree:
> 
> Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

patch has been applied to bluetooth-next tree.

Regards

Marcel

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
