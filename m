From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] drivers: net: Remove remaining alloc/OOM messages
Date: Fri, 08 Feb 2013 17:45:00 -0500 (EST)
Message-ID: <20130208.174500.1518593039138341685.davem@davemloft.net>
References: <1360273587.27863.15.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, wil6210-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1360273587.27863.15.camel@joe-AO722>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date: Thu, 07 Feb 2013 13:46:27 -0800

> alloc failures already get standardized OOM
> messages and a dump_stack.
> 
> For the affected mallocs around these OOM messages:
> 
> Converted kmallocs with multiplies to kmalloc_array.
> Converted a kmalloc/memcpy to kmemdup.
> Removed now unused stack variables.
> Removed unnecessary parentheses.
> Neatened alignment.
> 
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

Applied, thanks Joe.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
