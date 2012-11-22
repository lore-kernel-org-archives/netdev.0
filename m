From: Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Subject: Re: [PATCH 196/493] net/wireless: remove use of __devinit
Date: Thu, 22 Nov 2012 06:13:40 +0000 (GMT)
Message-ID: <1353564820.51519.YahooMailClassic@web172303.mail.ir2.yahoo.com>
References: <1353349642-3677-196-git-send-email-wfp5p@virginia.edu>
Reply-To: htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1353349642-3677-196-git-send-email-wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



--- On Mon, 19/11/12, Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org> wrote:

> From: Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
> Subject: [PATCH 196/493] net/wireless: remove use of __devinit
> To: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
> Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, "Jiri Slaby" <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Nick Kossifidis" <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>, "Simon Kelley" <simon-xn1N/tgparsycpQjotevgVpr/1R2p/CL@public.gmane.org>, "Stefano Brivio" <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>, "Stanislav Yakovlev" <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Dan Williams" <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Christian Lamparter" <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>, "Herton Ronaldo Krzesinski" <herton-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, "Hin-Tak Leung" <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, "Larry Finger" <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>, "Chaoming Li" <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>, "Luciano Coelho" <coelho-l0cyMroinI0@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> Date: Monday, 19 November, 2012, 18:22
> CONFIG_HOTPLUG is going away as an
> option so __devinit is no longer
> needed.
> 
> Signed-off-by: Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
> Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> 
> Cc: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Cc: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Cc: "Luis R. Rodriguez" <mcgrof-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
> 
> Cc: Simon Kelley <simon-xn1N/tgparsycpQjotevgVpr/1R2p/CL@public.gmane.org>
> 
> Cc: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>
> 
> Cc: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 
> Cc: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
> 
> Cc: Herton Ronaldo Krzesinski <herton-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> Cc: Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> 
> Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> 
> Cc: Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
> 
> Cc: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org> 
> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> 
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> 
> Cc: ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
> 
> Cc: b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> 
> Cc: brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
> 
> Cc: libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> 
> ---

Acked-by: Hin-Tak Leung <htl10-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

The rtl818x parts.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
