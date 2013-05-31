From: Solomon Peachy <pizza-pCgMCH4qpMRg9hUCZPvPmw@public.gmane.org>
Subject: Re: cw1200 "sbus" conflicts with SPARC "sbus"
Date: Fri, 31 May 2013 08:05:54 -0400
Message-ID: <20130531120553.GA31667@shaftnet.org>
References: <alpine.DEB.2.00.1305311127200.4645@ayla.of.borg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HcAYCG3uE/tztfnV"
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1305311127200.4645-97SZ98TBZzA1xEWliksxXw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--HcAYCG3uE/tztfnV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 31, 2013 at 11:31:05AM +0200, Geert Uytterhoeven wrote:
>=20
> sparc64/allmodconfig:
>=20
> drivers/net/wireless/cw1200/hwio.c:51:21: error: macro "sbus_memcpy_fromi=
o" passed 4 arguments, but takes just 3
> drivers/net/wireless/cw1200/hwio.c:66:19: error: macro "sbus_memcpy_toio"=
 passed 4 arguments, but takes just 3
>=20
> http://kisskb.ellerman.id.au/kisskb/buildresult/8846508/
>=20
> At first I thought it was a bad/old implementation of a real SPARC sbus
> driver.  but it seems the two sbusses are completely unrelated.

Yikes.=20

Would it be sufficient to just rename that pair of macros, or should I=20
go and rename entire cw1200's "bus" subsystem?

Either way, I'll add this to the to-do list for the weekend.

 - Solomon
--=20
Solomon Peachy        		       pizza at shaftnet dot org	=20
Delray Beach, FL                          ^^ (mail/jabber) ^^
Quidquid latine dictum sit, altum viditur.

--HcAYCG3uE/tztfnV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iD8DBQFRqJIhPuLgii2759ARAqnIAKDuJmGl4GdnnN8FYROfmonYfRM2YACfU1oI
2WFw0GyBMlsAqdXHjnUrw40=
=SbeX
-----END PGP SIGNATURE-----

--HcAYCG3uE/tztfnV--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
