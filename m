From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/2] r8152: use eth_hw_addr_random
Date: Wed, 03 Sep 2014 10:33:12 +0200
Message-ID: <87egvtyugn.fsf@nemi.mork.no>
References: <1394712342-15778-26-Taiwan-albertk@realtek.com>
	<1394712342-15778-29-Taiwan-albertk@realtek.com>
	<1394712342-15778-31-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-31-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org> (Hayes Wang's
	message of "Wed, 3 Sep 2014 10:59:15 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org> writes:

> +		ether_addr_copy(dev->perm_addr, dev->dev_addr);

This isn't strictly necessary.  register_netdev() will do it for you as
long as you leave the default addr_assign_type (NET_ADDR_PERM).  And yo=
u
do.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
