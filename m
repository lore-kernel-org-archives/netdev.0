From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [patch v2] net/usb: remove err() messages in few drivers
Date: Tue, 13 Jan 2009 17:05:50 -0800
Message-ID: <200901131705.50775.david-b@pacbell.net>
References: <1231805322.12962.4.camel@tux.localhost> <200901131207.03724.oliver@neukum.org> <208cbae30901131622heccfee6uf312022ba1d4fb28@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Oliver Neukum" <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	"Greg KH" <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Alexey Klimov" <klimov.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <208cbae30901131622heccfee6uf312022ba1d4fb28-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 January 2009, Alexey Klimov wrote:
> > Use the interface passed into probe(): =A0dev_err(&intf->dev, ...) =
etc
>=20
> Well, in few v4l-dvb drivers successfully used &radio->usbdev->dev in
> debug messages and that doesn't look wrong.

Use intf->dev ... always.  You may need to save the interface
in probe(), but that's easy.

"Doesn't look wrong" is incorrect; it doesn't list the driver
which issued it.  Which makes it harder to track down exactly
what issued the message, and thence what it really means.

- Dave
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
