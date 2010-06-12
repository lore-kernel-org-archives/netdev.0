From: Dmytro Milinevskyy <milinevskyy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [ath5k-devel] [PATCH] [ath5k][leds] Ability to disable leds
	support. If leds support enabled do not force mac802.11 leds layer selection.
Date: Sat, 12 Jun 2010 05:02:53 +0300
Message-ID: <AANLkTinA0cEXRVtD8iP1UhOsdYsSRONagfX7yQbMl_DG@mail.gmail.com>
References: <4c0f4326.0a41df0a.7bde.ffffeef2@mx.google.com>
	<AANLkTilrYYHjcMEhhrP7zjcLoo-TNczozxJSNRkDvSZy@mail.gmail.com>
	<AANLkTimXqdkQxv_Y1JaleTTWNsDIQHQaPn8HR7efOupb@mail.gmail.com>
	<1276286993.3918.0.camel@jlt3.sipsolutions.net> <AANLkTim90VBfWjp2YPYeYN6ImjIyZzcJ_XnpT5cdgCt4@mail.gmail.com>
	<1276288163.3918.1.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	GeunSik Lim <geunsik.lim-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Keng-Yu Lin <keng-yu.lin-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Shahar Or <shahar-ThuA2tnqEQ612v9G2T7xgg@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Luca Verdesca <magooz-JapBdFJSX0s@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1276288163.3918.1.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In this case no way to control LEDs. If you turn LEDs support you
can't tune them out, no?

I believe that user should be able to chose whether LEDs support is
needed or not. This is how done in intel wireless drivers. The driver
should be tolerant.

-- Dima

On Fri, Jun 11, 2010 at 11:29 PM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Fri, 2010-06-11 at 23:26 +0300, Dmytro Milinevskyy wrote:
>> Generic LED class is not disabled so it's possible to control leds in sysfs.
>
> But if you turn off ATH5K_LEDS??
>
> johannes
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
