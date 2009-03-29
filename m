From: Harald Welte <laforge@netfilter.org>
Subject: Re: linux-next: Tree for March 27 (netfilter build error)
Date: Sun, 29 Mar 2009 13:48:33 +0200
Message-ID: <20090329114833.GM15306@prithivi.gnumonks.org>
References: <20090328102852.GA7697@localhost> <49CEF882.5000005@oracle.com> <20090329064704.GA7255@localhost> <20090328.234739.26481917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lCFQJunhLz1tFGpX"
Cc: gorcunov@gmail.com, randy.dunlap@oracle.com, pablo@netfilter.org,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090328.234739.26481917.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--lCFQJunhLz1tFGpX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Sat, Mar 28, 2009 at 11:47:39PM -0700, David Miller wrote:
> From: Cyrill Gorcunov <gorcunov@gmail.com>
> Date: Sun, 29 Mar 2009 10:47:04 +0400
>=20
> > [Randy Dunlap - Sat, Mar 28, 2009 at 09:26:42PM -0700]
> > ...=20
> > | works_for_me.  Thanks.
> > | but missing S-O-B.
> > |=20
> > | Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
> > ...
> >=20
> > Thanks for testing Randy. So if nobody will complain
> > here is a solid version of the patch. Though I would like
> > if Pablo or Patrick confirm its correctness. Thanks!
>=20
> I'll apply this once Patrick or Pablo have a look at it.

I'm neither of them but I strongly believe the patch is correct.  =20

The only question that Patrick raised during the discussion of this patch s=
ome
days ago is whether the __ipv6_addr_type() call would cause a runtime
dependency to thei ipv6 module.  This would be bad since loading the
xt_cluster.ko module should not pull in the IPv6 protocol module.

I have just verified that __ipv6_addr_type is provided by
net/ipv6/addrconf_core.c, which specifically states it contains functions
"needed by static components when full IPv6 support is not configured or
static".   This is confirmed by the makefile, which addes addrconf_core.o to
obj-y.

So from my point of view, I cannot see any problems.

Regards.
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--lCFQJunhLz1tFGpX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQFJz2ARXaXGVTD0i/8RAoCBAJ4jTchisJoRx+19Oj8Iy54PNOA6xQCdGq8D
L3m5X4n28okQ74uvT2EP3N8=
=OYRA
-----END PGP SIGNATURE-----

--lCFQJunhLz1tFGpX--
