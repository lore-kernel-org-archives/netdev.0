From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 19 Jan 2005 09:03:42 -0600
Message-ID: <200501190903.45671.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501141326.29575.jeremy.guthrie@berbee.com> <16874.24305.461492.48668@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1140883.XAXnEGKz2f";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16874.24305.461492.48668@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1140883.XAXnEGKz2f
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 16 January 2005 06:32 am, Robert Olsson wrote:
>  Some time ago an "in-flow" GC (as opposed to timer based) was added to
>  the routing code look for cand in route.c. In setup like yours (and ours)
>  it would be better to relay on this process to a higher extent. Anyway
>  in /proc/sys/net/ipv4/route/ you have the files.
>
>  gc_elasticity, gc_interval, gc_thresh etc I would avoid gc_min_interval.
>
>  And you can play with your running system and for drops without causing
>  your users to much pain.
I have done a little tweaking.  I now hold at around 520K routes in the has=
h. =20
I still drop packets every secret_interval but I've upped that counter so I=
=20
don't whack all of my hash entries all that often.

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1140883.XAXnEGKz2f
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB7nbRqtjaBHGZBeURAlELAKCXBqq6fxLX9IOJiMYzGuTiaeGP6QCffX6C
5h7IY4v/kvc4yavt1ej7grk=
=Mgdd
-----END PGP SIGNATURE-----

--nextPart1140883.XAXnEGKz2f--
