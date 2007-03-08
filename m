From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Thu, 08 Mar 2007 20:40:01 +0100
Message-ID: <1173382802.3248.68.camel@johannes.berg>
References: <1173144447.15891.93.camel@johannes.berg>
	 <20070306171316.GA19669@bougret.hpl.hp.com>
	 <200703061943.07350.mb@bu3sch.de>
	 <20070307020310.GA20466@bougret.hpl.hp.com>
	 <1173364747.14001.7.camel@johannes.berg>
	 <20070308184954.GA24485@bougret.hpl.hp.com>
	 <1173382042.3248.63.camel@johannes.berg>
	 <20070308193412.GG23040@devicescape.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-AQ2J+NA0w52xtbr+ov3N"
Cc: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070308193412.GG23040-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-AQ2J+NA0w52xtbr+ov3N
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-03-08 at 11:34 -0800, Jouni Malinen wrote:

> Yes, workaround in just iwlib is not enough. If the only possible
> solution is user space workaround, it better be documented (and
> communicated to maintainers of user space apps) well so that
> all user space programs not using iwlib can be modified, too.

The more I think about it the worse it gets. Think about wireless events
where both 32 and 64-bit userspace programs may be listening... That
means we can't even fix it in the kernel without breaking something.

johannes

--=-AQ2J+NA0w52xtbr+ov3N
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBF8GaR/ETPhpq3jKURAkspAJ0eKz/C5kNMF2fmYcHhBdxs2S+yVwCggqKo
a3rmXJie8QsxDNHH6YhGWMo=
=Hxg6
-----END PGP SIGNATURE-----

--=-AQ2J+NA0w52xtbr+ov3N--
