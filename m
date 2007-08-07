From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] drivers/net/wireless/wl3501_cs.c: remove redundant
	memset
Date: Mon, 6 Aug 2007 20:11:55 -0400
Message-ID: <20070807001155.GA3285@tuxdriver.com>
References: <200708070050.23158.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org, Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mariusz Kozlowski <m.kozlowski-NWF1p15JEu3VItvQsEIGlw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200708070050.23158.m.kozlowski-NWF1p15JEu3VItvQsEIGlw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Please send wireless patches to linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
and CC me.

Thanks!

John

On Tue, Aug 07, 2007 at 12:50:22AM +0200, Mariusz Kozlowski wrote:
> Hello,
> 
> 	This memset() looks superfluous.
> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski-NWF1p15JEu3VItvQsEIGlw@public.gmane.org>
> 
>  drivers/net/wireless/wl3501_cs.c | 58885 -> 58858 (-27 bytes)
>  drivers/net/wireless/wl3501_cs.o | 200252 -> 200000 (-252 bytes)
> 
>  drivers/net/wireless/wl3501_cs.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> --- linux-2.6.23-rc1-mm2-a/drivers/net/wireless/wl3501_cs.c	2007-08-01 08:43:46.000000000 +0200
> +++ linux-2.6.23-rc1-mm2-b/drivers/net/wireless/wl3501_cs.c	2007-08-07 00:34:36.000000000 +0200
> @@ -1841,7 +1841,6 @@ static int wl3501_get_encode(struct net_
>  	tocopy = min_t(u8, len_keys, wrqu->encoding.length);
>  	tocopy = min_t(u8, tocopy, 100);
>  	wrqu->encoding.length = tocopy;
> -	memset(extra, 0, tocopy);
>  	memcpy(extra, keys, tocopy);
>  out:
>  	return rc;
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
