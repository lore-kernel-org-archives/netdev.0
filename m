From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 0/3] wireless extensions improvements
Date: Fri, 26 Jun 2009 22:12:47 +0200
Message-ID: <1246047167.21314.61.camel@johannes.local>
References: <20090624113447.441667549@sipsolutions.net>
	 <20090625.161817.112930127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-7+yRh/nD94Y0iQwlgmX0"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090625.161817.112930127.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-7+yRh/nD94Y0iQwlgmX0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-06-25 at 16:18 -0700, David Miller wrote:

> These changes look fine to me, so I'll likely put them into
> net-next-2.6 as soon as I open that up.

Alright, sounds good.

> FWIW, I bet we could make read() easily work properly to for the
> compat stuff, and it would be nice to shore up that one minor hole.

Yes, but I think that would require introducing compat_sys_read() and
touching all architectures.

One other thing I just thought about -- the things you were mentioning
wrt. u64 alignment, is that relevant for sendmsg() as well? This doesn't
cover that at all, so far, obviously. If that would be needed, we'd also
need more work there, we can of course do that as we go along and add
code to deal with just the kernel->userspace messages where necessary.

johannes

--=-7+yRh/nD94Y0iQwlgmX0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKRSu8AAoJEODzc/N7+QmaQr0QAKX/TqjXZslAvmhIZYNbf2VM
zwyEu9/Nii/2WNrbPtSlP3384Fo3OpgvkK2517yGa8yw+S4Fjsv9ypJ3t4tN9WmQ
NfbUaJE/tOoduYoLvgkc28emmrhzy8d0V+Sde3s1m1SLDnFNGHj18xvc/hdiXsPB
dBfnt8OCTznlsAbGQqdddQVCikC5txAj1jmkCdug5ZY5+j8QhXyllbPFEjjghhlb
ZRfpoBOKpgm244gmV/0F5TY7VENlxFA22HsTlBOOSX4DdIc6sANieKYHymxtvX+z
JTd83bI4+DaI6t2KG6puCKtZE2hL+jZGwPXXsltEppPAskGjcELFb+MW93iJkumE
NpmYbRdQrF5KlT+xV10BKpYGlJTe3NAqGu0a3+HTeFRHw7/cgo3ZetqL/uhi0GHw
m9/lfEazHCw2djDrT4AELnyFah7vufLS/qEh3QH1l9Gg9DDAQCpXcFdip2t1gfHQ
GWfMrpMYZrysWoZlDb8wPNn+8uMN8nWNvUCjWBOprEastgtqfKwy5PUxadqTKCwX
Mxpf8p7Lj4EmRTx4Lgsq2gf3U+oFZjLkoNdUfU5ovHmC/Jr7e7XDOD5885vAzDgo
zEn8Jzov96SPu5x7/PK830C5Y93PK6khE8BsBWytTDmpE8VNJ14pGcodalTvqGAY
lA3fbMKCbJnCSXTsG4zc
=6wJJ
-----END PGP SIGNATURE-----

--=-7+yRh/nD94Y0iQwlgmX0--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
