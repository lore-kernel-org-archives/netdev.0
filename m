From: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [announce] new rt2800 drivers for Ralink wireless & project tree
Date: Fri, 6 Nov 2009 19:30:13 +0100
Message-ID: <200911061930.13069.bzolnier@gmail.com>
References: <200911031951.05235.bzolnier@gmail.com> <20091106074643.GA5562@ucw.cz> <200911061858.56816.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>,
	Luis Correia <luis.f.correia-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200911061858.56816.IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 06 November 2009 18:58:56 Ivo van Doorn wrote:

> drivers/net/staging/rt28{6,7}0 was developed by Ralink and I acked

The original vendor drivers were:
- rt2860
- rt2870
- rt3070
- rt3090

Each weighting ~100 KLOC.

The current staging drivers (rt2860 w/ RT3090 support and rt2870 w/ RT3070
support) are the result of my work on getting staging drivers under control
(+ trying some new strategies of dealing with ugly code) and weight ~75 KLOC
_together_ (they share the wireless stack code).

> the merged for those drivers after the asurance that it was only merged
> to please the users so developers could focus on the rt2x00 version of
> the driver.

Could somebody please explain me (in the public or in the private) what is
the reason behind whole affair about staging drivers because all the time
I feel like I'm missing some important detail here.  It would a lot more
productive than all the things that I could hear about my agenda, my work
or my intellectual abilities in the past.

[ Like I said before I got only interested into them in April this year
  while doing casual staging cleanups and I'm not affiliated with any
  distribution vendor. ]

Thanks.
-- 
Bartlomiej Zolnierkiewicz
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
