From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 7/9] wext: reduce inline abuse
Date: Thu, 26 Apr 2007 19:14:05 +0200
Message-ID: <1177607646.6814.106.camel@johannes.berg>
References: <20070424180732.371620000@sipsolutions.net>
	 <20070424180849.651555000@sipsolutions.net>
	 <20070426165032.GB22576@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-y3qfPucXZSNHhXurlwUE"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070426165032.GB22576-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-y3qfPucXZSNHhXurlwUE
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-04-26 at 09:50 -0700, Jean Tourrilhes wrote:

> 	That's clearly not true of all compilers. All gcc versions
> before 4.0 need serious help to inline functions used only once. Our
> current minimal requirement for the kernel is gcc 3.2, therefore this
> code is still useful.
> 	Note that this is a legitimate use of inline (tell the
> compiler to inline the function), not an abuse.

No, the abuse is using inline in the first place because it doesn't
matter, none of this has an actual reason to be inlined.

johannes

--=-y3qfPucXZSNHhXurlwUE
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGMN3d/ETPhpq3jKURAlFeAJ0d3nWHI8bXfWWdOFVAii+GAz5dtwCgtj3t
F2zsmBU7+QilMa474j3nijA=
=T5HB
-----END PGP SIGNATURE-----

--=-y3qfPucXZSNHhXurlwUE--
