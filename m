From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix for oops on resume
Date: Wed, 07 Feb 2007 13:15:49 +0100
Message-ID: <1170850549.6798.22.camel@johannes.berg>
References: <45c8bd59.oamnvaNRMZvKoPBa%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-nIAeVNKkW8S0delCnSTK"
Cc: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <45c8bd59.oamnvaNRMZvKoPBa%Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-nIAeVNKkW8S0delCnSTK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-02-06 at 11:39 -0600, Larry Finger wrote:
> There is a kernel oops on bcm43xx when resuming due to an overly tight ti=
meout loop.

Come to think of it... Is there any chance of fixing the actual oops
that happens in this case? I can imagine broken hardware or firmware
that causes this as well and we don't really want to oops in that case
either... That's why we have the timeout in the first place, to not hang
there forever.

Nothing against this patch though.

johannes

--=-nIAeVNKkW8S0delCnSTK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFycL1/ETPhpq3jKURAr3PAKC1GFxqEpU6pUw+vRwN5Cjnf1SIdwCfUu9L
iPcN5QVP51rRYtc8YwE3A7Y=
=cvY/
-----END PGP SIGNATURE-----

--=-nIAeVNKkW8S0delCnSTK--

-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
