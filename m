From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 1/2] usbnet: Convert dev(dbg|err|warn|info) macros to netdev_<level>
Date: Sun, 14 Feb 2010 19:09:06 -0800
Message-ID: <201002141909.06541.david-b@pacbell.net>
References: <20100212.123837.56526847.davem@davemloft.net> <4B7892AA.7000305@imap.cc> <1266195287.16721.953.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Greg Kroah-Hartman" <gregkh-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1266195287.16721.953.camel-AkRN8/LKpobuYGix6ZUp1Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 14 February 2010, Joe Perches wrote:
> I'll resend in a bit after David Brownell or
> someone else answers the inverted question below.
>=20
> > Btw, is it intentional that the _OTHER values are printed after the
> > label "this", and the _THIS values after the label "other"?
>=20
> Thanks again, I saw that, but neglected to mention it.
> David Brownell? =A0Do you know if that is inverted?

I'd call that a bug.  Note that this is specific to the net1080
chip, which hasn't been manufactured for quite a few years now
and was never hugely popular ... so the significance of getting
that rarely-seen diagnostic wrong was minor.

- Dave



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
