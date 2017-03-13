From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v7 0/6] Bluetooth: 6LoWPAN: Fix lladdr length
Date: Mon, 13 Mar 2017 15:40:25 -0700 (PDT)
Message-ID: <20170313.154025.2280737153222354061.davem@davemloft.net>
References: <20170312081938.11700-1-luiz.dentz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170312081938.11700-1-luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Sun, 12 Mar 2017 10:19:32 +0200

> From: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> These patches fixes lladdr length to be 6 bytes long and not 8 which cause
> neighbor advertisement to be sent with wrong lladdr including FF:FE filler
> bytes for eui64.
> 
> Note: This does not fix some of the existing crashes which I hope to address
> in a different set.
> 
> v2: Make all code paths that generate a link-local from lladdr use the same
> code.
> v3: Use lowpan_iphc_uncompress_eui48_lladdr to generate the remote ip address.
> v4: Handle comments from Stefan Schmidt.
> v5: Add patch to fix IID format for Bluetooth
> v6: Fix addrconf_ifid_eui48 to follow IID format for Bluetooth
> v7: Rework addrconf_ifid_6lowpan so it doesn't use addrconf_ifid_eui48

Since this is predominantly bluetooth/6lowpan stuff, please merge this via
the bluetooth tree.

Thanks!
