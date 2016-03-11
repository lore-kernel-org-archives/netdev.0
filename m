From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH 3/3] dm9601: add support ethtool style utility
Date: Fri, 11 Mar 2016 11:42:13 +0000
Message-ID: <1457696533.3001.88.camel@decadent.org.uk>
References: <201603111110.u2BBAiwV020429@mail.davicom.com.tw>
	 <1457696013.3001.86.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-67Ln/kOl0cNGBHFHdhDz"
To: Joseph Chang <joseph_chang-Ubu6M+hUeUGoECsaD+WFmw@public.gmane.org>,
	'Joseph CHANG' <josright123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	'Peter Korsgaard' <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1457696013.3001.86.camel-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-67Ln/kOl0cNGBHFHdhDz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-11 at 11:33 +0000, Ben Hutchings wrote:
> On Fri, 2016-03-11 at 19:08 +0800, Joseph Chang wrote:
> >=20
> > I tested by
> > =C2=A0./ethtool -E eth0 magic 0x9620 offset 0 length 3 value 0xf1 value=
 0xf2 value 0xf3
> >=20
> > I think ethtool need [ value N ] for each byte (so need three "value xx=
" in above command line),=C2=A0
> > am I right?
> >=20
> > Oh, I can see it goes wrong~ Thanks~
> [...]
>=20
> You can only pass one byte on the command line and that forces the
> length to be 1. =C2=A0To set multiple bytes, you need to provide them on
> stdin instead.

...as raw binary data, not hexadecimal strings.

Ben.

--=20
Ben Hutchings
73.46% of all statistics are made up.
--=-67Ln/kOl0cNGBHFHdhDz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW4q8VAAoJEOe/yOyVhhEJvroP+wb0jjOwt7LE9KYBcImU+D0l
U17mwM7Sdhj4/UAribzx2dLqU0gaj7HdnofM91DnJM5sJl8Kogiv69oRwYj1DOea
Bo9KnliRUP4O13ufl0Uidz7fFsBXK2yOQXc4C/+NYD0VNnaBr9G6FPNmYSi7vfSl
Fvzkpye2s6mhzMJtMGdm/MmbCteUsx/Cxb375q47I4WK9lqKouiXM5JPIZj4UJ3a
E1YViQvMCRnk3ggZt4Py+KC9wSBSjBZXnHC/dbEm5RRzAROF2Xi6QOy6TQMB7eKY
sWm5dnJN1+MB3dq1jiqpNm+96NU5snUPbWlYs1eJztYVp9bbHLSxz29cPTxk/pKS
MjYIKHL3PcDqWpRNES9wMqsk6ZC24qSiNo804s4tHxGASyP+s0VEYXDjIkATPf14
3VPWtB8GdkuhbbWGLb+acRsdPhO1VwkjgLbTi62rOePzLag4B4eqPdyXlkr/jT8Y
N249cvEz+amTTuv9f7b98m3EiyQHPnrVNn9wLuIO/Saf5DLc2/tiXpqrJ4Wm8aGH
Y6oPlh7cptZ4MCWhQOmVPvufpr90oplL1hdR4ShRkE8H2Cr18MoIFNWy6yuNENAi
U4Nf/BoiTGPVgNak36vI6PzrjJMbDGv6SPxDRLwBatvsSKsQZNwWUCYqf6OCBwj/
oixzt+bBbuzJw98t64op
=PWdz
-----END PGP SIGNATURE-----

--=-67Ln/kOl0cNGBHFHdhDz--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
