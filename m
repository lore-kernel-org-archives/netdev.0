From: Florian Bruhin <me-J2duszcpOy900TDglC2tyg@public.gmane.org>
Subject: Re: [PATCH net,stable-4.0] cdc_ncm: Fix tx_bytes statistics
Date: Sat, 23 May 2015 11:27:08 +0200
Message-ID: <20150523092708.GA23152@tonks>
References: <1432293322-11928-1-git-send-email-bjorn@mork.no>
 <20150522.143421.442426385899149301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256; protocol="application/pgp-signature"; boundary="=_mehl.schokokeks.org-26073-1432373230-0001-2"
Cc: bjorn-yOkvZcmFvRU@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150522.143421.442426385899149301.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_mehl.schokokeks.org-26073-1432373230-0001-2
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> [2015-05-22 14:34:21 -0400]:
> From: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> Date: Fri, 22 May 2015 13:15:22 +0200
>=20
> > The tx_curr_frame_payload field is u32. When we try to calculate a
> > small negative delta based on it, we end up with a positive integer
> > close to 2^32 instead.  So the tx_bytes pointer increases by about
> > 2^32 for every transmitted frame.
> >=20
> > Fix by calculating the delta as a signed long.
> >=20
> > Cc: Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
> > Reported-by: Florian Bruhin <me-J2duszcpOy900TDglC2tyg@public.gmane.org>
> > Fixes: 7a1e890e2168 ("usbnet: Fix tx_bytes statistic running backward i=
n cdc_ncm")
> > Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>=20
> Applied and queued up for -stable.

Thank you, and thanks Bj=F8rn for the quick fix!

Florian

--=20
http://www.the-compiler.org | me-J2duszcpOy900TDglC2tyg@public.gmane.org (Mail/XMPP)
   GPG: 916E B0C8 FD55 A072 | http://the-compiler.org/pubkey.asc
         I love long mails! | http://email.is-not-s.ms/

--=_mehl.schokokeks.org-26073-1432373230-0001-2
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVYEfsAAoJEJFusMj9VaBya8EP/0GLVUah5Hh0aINlzB+Yoy9g
7j1qvYqY9DSmGXx0rll8gyvmB0iydxA5fxJ+Kae4quwk2D8sRmgPGv3+yMyogFau
6rWlW8r0DpfTZb8WQxCffHgzgsFTrX3YgpahOBqowdqisv6WmKjwFK225LXcxwDJ
BRI7TT5xl5kS+2q6hhbXOTeyYrm1q1YLtOumDbpIwIkLMtmKbbWsi43GKjFyl7Ql
/VWUdlsWYaMI5yqUGjPYLRMxBXt9E3kibpKzpOtMokQvz8lF8F42p+vgQ2fRMlWt
Q1xz6n4rolGX/H5w8LsVD4Aap4VzX2pYKWlXj6uTfvFxd1RzeSS+9U1JTUDbR07W
dl+uTxx6rqCc5NvYrh0CXo3r622FmPFhNhnVVIYmheZvZzdxmx8SdrPM0ijnlkpl
ZCfqhQJc6ZMpPJY6RvDCJyVKzEoeanmpcDNMFgxEHFiZR4TX9p9pimhwN757CL4N
SK+aBlHJvtNZ2ssu5v7W0+7N0ZdM7x/JWOJnCvcleZt7z+/Gkf2mVW39vZGfzWlC
hay0TFAVAC9PwkPcZY+AXQZW4y2FsyTrg1P6aGKVpIZe7WP0kFIBTH2SF3dAvDKs
O+lDpA+EkiURgRTkIliK0n2nUs/ToytX2gMmHK2bATAYr8OkXU1341tGA0iZI5yA
ViuarL4XV57yovx4w1Nf
=8hZL
-----END PGP SIGNATURE-----

--=_mehl.schokokeks.org-26073-1432373230-0001-2--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
