From: Harald Welte <laforge@netfilter.org>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere
	else")
Date: Tue, 31 Aug 2004 14:16:58 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040831121658.GE5824@sunbeam.de.gnumonks.org>
References: <20040830191915.04d49268.davem@davemloft.net>
	<E1C1yRs-00086x-00@gondolin.me.apana.org.au>
	<20040830223920.1db0d5ae.davem@davemloft.net>
	<Pine.LNX.4.58.0408310908120.4024@u.domain.uli>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BDlG3CzP/kphk9YG"
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
	Herbert Xu <herbert@gondor.apana.org.au>, rusty@rustcorp.com.au,
	kuznet@ms2.inr.ac.ru
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0408310908120.4024@u.domain.uli>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--BDlG3CzP/kphk9YG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 31, 2004 at 09:48:07AM +0300, Julian Anastasov wrote:

> 	So, if the input route for all packets selects dev1 before
> NAT but MASQUERADE selects different device (nexthop) bad things
> happen. It costs routing cache entries to provide oif key but almost
> in any case the right gateway is selected (except when two nexthops
> use same device).

I am willing to compromise at that cost.  I cannot imagine a combination
of dynamic IP with multiple nexthop on the same device.  Getting those
policy routing / DSL / dynip / MASQUERADE cases right is definitely more
important.

Any static IP case should be using SNAT, that's always been documented.

> Regards

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--BDlG3CzP/kphk9YG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBNGw6XaXGVTD0i/8RAqk7AJ98tc9bjQFDS8TJeLVlIM6H2UwA5ACeJU7U
eSZ7LFrulPDIrw22eT57D+M=
=2hzH
-----END PGP SIGNATURE-----

--BDlG3CzP/kphk9YG--
