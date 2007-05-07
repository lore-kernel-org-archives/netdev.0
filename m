From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH v2] Add rtl8187 wireless driver
Date: Mon, 7 May 2007 19:17:20 -0400
Message-ID: <200705071917.25414.flamingice@sourmilk.net>
References: <200705071022.11711.flamingice@sourmilk.net> <463F44E6.5030705@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2189907.2cFA0iq48g";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Andrea Merello <andrea.merello-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <463F44E6.5030705-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart2189907.2cFA0iq48g
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 07 May 2007 11:25, Jeff Garzik wrote:
> I am a bit skeptical that multiple files are needed.  It seems like
> drivers/net/wireless/rtl818x.c would be a better path, a la tg3.c.
>
The radio tuning stuff could be stuffed into rtl8187_dev.c, but I like to k=
eep=20
it separate since rtl8187_rtl8225.c tends to contain all the radio tuning=20
black magic that no one really understands except for the engineers at=20
Realtek, whereas rtl8187_dev.c is mostly straightforward. rtl8187 can also=
=20
(in theory) use another radio chip (rtl8255). The two headers - rtl818x.h a=
nd=20
rtl8187.h cannot be merged because the definitions in rtl818x.h are shared=
=20
between the usb and pci drivers.

I rather not combine any files, though I don't mind collapsing the driver=20
another level. However, I think other driver authors much prefer having the=
ir=20
own directory, and I'd like to keep the drivers consistently in their own=20
directory or all together in drivers/net/wireless.

=2DMichael Wu

--nextPart2189907.2cFA0iq48g
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBGP7OFT3Oqt9AH4aERAmm+AJ9q/zNHoJLkOw2AUfa7Ul6q/8gqSwCgv1mw
KoabnWvKEJnRtWzZ+5037Ec=
=Heln
-----END PGP SIGNATURE-----

--nextPart2189907.2cFA0iq48g--
