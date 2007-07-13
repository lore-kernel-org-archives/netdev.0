From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: d80211 deadlock with wpa_supplicant and rmmod
Date: Fri, 13 Jul 2007 23:45:16 +0200
Message-ID: <1184363116.3928.4.camel@johannes.berg>
References: <1caff7430707111617o70a534a5x2cf6b611a91f301a@mail.gmail.com>
	 <20070711234153.GB5099@tuxdriver.com>
	 <1184234538.6669.30.camel@johannes.berg>
	 <1caff7430707130505r579ef08cmacc6c77f7535a66c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-RucqRhR5xTmmQV7QIA41"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: seventh guardian <seventhguardian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1caff7430707130505r579ef08cmacc6c77f7535a66c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-RucqRhR5xTmmQV7QIA41
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-07-13 at 13:05 +0100, seventh guardian wrote:

> Hello, sorry for the delay but I only managed to try it out today..
> I've applied the patch and tortured the system as far as I could, and
> no hang at all :)
>=20
> I've read the thread and it apparently replaces one bad problem for a
> lesser one, so I understand if it's not applied.. But at least there
> is a place in the code to point as the culprit :)

It definitely should be applied anyway :) I guess John just hasn't
caught up with all threads yet.

John: This is about the patch in the "mac80211/bcm43xx deadlock" thread
from Michael, it kills some rtnl_lock()/unlock() that causes this
deadlock.

johannes

--=-RucqRhR5xTmmQV7QIA41
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGl/Jr/ETPhpq3jKURAsoKAJ4kmG99jFTH0u0WiCkR1WlcpXlosQCeJJc2
62yOqMlYCaThL6CpS8PprkI=
=kbeB
-----END PGP SIGNATURE-----

--=-RucqRhR5xTmmQV7QIA41--
