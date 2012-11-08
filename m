From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 0/2] Fix CDC_EEM with 802.1Q VLAN and 1500 MTU
Date: Wed, 07 Nov 2012 21:27:52 -0500 (EST)
Message-ID: <20121107.212752.1709967292920700431.davem@davemloft.net>
References: <1352335159-8049-1-git-send-email-iancoolidge@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: iancoolidge-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1352335159-8049-1-git-send-email-iancoolidge-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ian Coolidge <iancoolidge-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed,  7 Nov 2012 16:39:17 -0800

> cdc_eem USB host driver and gadget driver both are broken in 1500 MTU
> case while using 802.1Q VLANs. In both cases, this is due to the
> assumption of standard Ethernet frame length.
> 
> v2: rebase against Dave Miller's 'net/master' tree
> 
> Ian Coolidge (2):
>   usb: gadget: g_ether: fix frame size check for 802.1Q
>   net: usb: cdc_eem: Fix rx skb allocation for 802.1Q VLANs

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
