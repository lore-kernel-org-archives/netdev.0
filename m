From: Michal Vanco <vanco@satro.sk>
Subject: Re: 2.6.11 on AMD64 traps
Date: Wed, 9 Mar 2005 21:42:49 +0100
Message-ID: <200503092142.50027.vanco@satro.sk>
References: <200503081900.18686.vanco@satro.sk> <200503092124.35190.vanco@satro.sk> <422F5DF0.6060904@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1338469.ckzsfZg8Zz";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <422F5DF0.6060904@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1338469.ckzsfZg8Zz
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 09 March 2005 21:34, Patrick McHardy wrote:
> Michal Vanco wrote:
> > On Wednesday 09 March 2005 20:45, Patrick McHardy wrote:
> >>This patch should fix it. The crash is caused by stale pointers,
> >>the pointers in fib_iter_state are not reloaded after seq->stop()
> >>followed by seq->start(pos > 0).
> >
> > Well. Trap vanished after applying this patch, but another weird thing
> > occurs:
> >
> > # ip route show | wc -l
> > 156033
> > # date; time ip route show > /dev/null; date; time netstat -rn >
> > /dev/null Wed Mar  9 22:15:21 CET 2005
> >
> > real    0m0.656s
> > user    0m0.415s
> > sys     0m0.242s
> > Wed Mar  9 22:15:22 CET 2005
> >
> > real    6m41.472s
> > user    0m1.261s
> > sys     6m40.143s
>
> Yes, I know it is totally inefficient. Just use ip route, which doesn't
> suffer from this problem.
>

Sure. Can (or will) this ever be fixed to any usable state also with netsta=
t?
Is this problem related only to AMD64?

regards,
=2D-=20
Ing. Michal Van=C4=8Do
Network Engineer
SATRO s.r.o.
e-mail: vanco@satro.sk

--nextPart1338469.ckzsfZg8Zz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQBCL1/JSBxxqpMaGkMRAncMAKC0uP10O/lE1ssSDeb8Bg1v4TXQlwCfVo5h
fq/IsEk9ojedms9RJPDdDtw=
=alsO
-----END PGP SIGNATURE-----

--nextPart1338469.ckzsfZg8Zz--
