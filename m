From: Michal Vanco <vanco@satro.sk>
Subject: Re: 2.6.11 on AMD64 traps
Date: Wed, 9 Mar 2005 22:17:00 +0100
Message-ID: <200503092217.01106.vanco@satro.sk>
References: <200503081900.18686.vanco@satro.sk> <200503092142.50027.vanco@satro.sk> <422F6517.6070301@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2112481.KRQqhVlnu6";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@oss.sgi.com
In-Reply-To: <422F6517.6070301@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2112481.KRQqhVlnu6
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 09 March 2005 22:05, Patrick McHardy wrote:
> Michal Vanco wrote:
> > On Wednesday 09 March 2005 21:34, Patrick McHardy wrote:
> >>Yes, I know it is totally inefficient. Just use ip route, which doesn't
> >>suffer from this problem.
> >
> > Sure. Can (or will) this ever be fixed to any usable state also with
> > netstat? Is this problem related only to AMD64?
>
> Maybe. To start dumping entries of an open hashed hash-table at a
> specific position we need to skip all entries before that position by
> walking over them. This results in quadratic time complexity. It might
> be possible to improve this by cacheing the last position in
> fib_iter_state even between ->stop() and ->start() calls and using
> generation IDs for invalidation.
>

Ok. Thank's for help.

regards,
Michal

--nextPart2112481.KRQqhVlnu6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD4DBQBCL2fNSBxxqpMaGkMRAssVAJdZmGvV0Q1or0ISlwKD2ouVrqwoAJ9pw3VQ
+UIGlGHHGjOsRVZkLThTDg==
=JAAy
-----END PGP SIGNATURE-----

--nextPart2112481.KRQqhVlnu6--
