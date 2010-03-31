From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [r8169] WARNING: at net/sched/sch_generic.c
Date: Wed, 31 Mar 2010 16:49:36 +0300
Message-ID: <20100331134936.GC3294@swordfish.minsk.epam.com>
References: <20100331102142.GA3294@swordfish.minsk.epam.com>
 <20100331111942.GB13963@hmsreliant.think-freely.org>
 <20100331121426.GB3294@swordfish.minsk.epam.com>
 <1270038569.2103.24.camel@edumazet-laptop>
 <20100331133533.GD13963@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZwgA9U+XZDXt4+m+"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100331133533.GD13963@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ZwgA9U+XZDXt4+m+
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On (03/31/10 09:35), Neil Horman wrote:
> On Wed, Mar 31, 2010 at 02:29:29PM +0200, Eric Dumazet wrote:
> > Le mercredi 31 mars 2010 =E0 15:14 +0300, Sergey Senozhatsky a =E9crit :
> >=20
> >=20
> > > PKT_SIZE=3D"pkt_size 2048"
> > >=20
> >=20
> > If you use 1024 bytes pktgen messages, do you still have the problem ?
> >=20
> +1 I wouldn't be suprised if using something over the nominal 1522 byte f=
rame
> length on r8169 caused tx errors.  The driver doesn't seem to support Jum=
bo
> frames, so my guess is you have to keep the packet size below 1522 bytes.
> Neil

Hm. Good point. I'll test a bit later today.


	Sergey
--ZwgA9U+XZDXt4+m+
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkuzUvAACgkQfKHnntdSXjTS3QQAv/mmgkEndRrhAtBmcY6+yoXy
yy0ShNC3XGs4i0H81ojHEPruC120uPXMU+e75JfRuxDiSA81hUJvR1VLNk+lZ7uX
qse6OhEj/0YJK+x+q5MJPsgWKEuw+83fGQCUxNAXjtxpntR871U0X1qzcUwICZM2
0iJLR81BhfNAig97cCs=
=Tg5g
-----END PGP SIGNATURE-----

--ZwgA9U+XZDXt4+m+--
