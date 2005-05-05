From: Harald Welte <laforge@netfilter.org>
Subject: Re: CONFIG_NETFILTER_DEBUG spew
Date: Thu, 5 May 2005 13:14:57 +0200
Message-ID: <20050505111457.GS30482@sunbeam.de.gnumonks.org>
References: <20050501032809.3d0b4cda.akpm@osdl.org>
	<20050501111507.GA2133@gondor.apana.org.au>
	<4274F2ED.9080404@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+HM+R7/Jd0Fa6H3F"
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4274F2ED.9080404@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--+HM+R7/Jd0Fa6H3F
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, May 01, 2005 at 05:17:01PM +0200, Patrick McHardy wrote:
> You're right. I'm tempted to remove the entire nf_debug stuff,
> as far as I know it has never found a real bug. But for now
> I've only fixed the warning.

yes, I second that change.  At the same time, we should get rid of all
the lockhelp.h stuff that makes the netfilter code use non-standard lock
primitives.
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--+HM+R7/Jd0Fa6H3F
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQFCegAxXaXGVTD0i/8RAjw/AJ9gnJdmZW9GWXkPX+som+Fv9qDzxwCgqt1s
EaDWEpEUHlSFNzkq0nAsxy8=
=k6gh
-----END PGP SIGNATURE-----

--+HM+R7/Jd0Fa6H3F--
