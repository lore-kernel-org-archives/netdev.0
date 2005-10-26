From: Stephen Frost <sfrost@snowman.net>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Wed, 26 Oct 2005 09:37:36 -0400
Message-ID: <20051026133736.GP6026@ns.snowman.net>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
	<4352FD49.4090201@trash.net>
	<20051017014629.GB32661@gondor.apana.org.au>
	<435EBB18.50701@trash.net>
	<20051025231049.GA13679@gondor.apana.org.au>
	<435EBC57.7090000@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TrGrrwHz9iYGKlIl"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <435EBC57.7090000@trash.net>
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


--TrGrrwHz9iYGKlIl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* Patrick McHardy (kaber@trash.net) wrote:
> Herbert Xu wrote:
> > Actually I was thinking of transport mode SAs with no accompanying
> > tunnel mode SAs.  Did you have another way of dealing with them?
>=20
> No. I thought of this as a special case of inner transport mode SAs
> (without any further SAs) which would be unhandled. I've never used
> pure transport mode SAs except for testing, and I've never seen any
> other users of this. Do you think it is important to handle?

I've used pure transport mode SAs in a couple of cases and I do feel
they're important to support, and would really like to be able to use
firewall rules with them too..  In fact, I'd think it'd be more
important with transport-mode because it's more likely you'll want to
set up a pretty open use-ipsec-whenever-possible-with-remote-hosts mode,
unlike with tunnel mode where it's more likely you'll set up specific
policies which only accept tunnels which go to certain ports on certain
IPs, etc.  At least, I've set that up as well... :)

	Thanks,

		Stephen

--TrGrrwHz9iYGKlIl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDX4agrzgMPqB3kigRAjcPAKCKtdH5nSwHGOacjhlxasJKn8FNugCfb/IT
7qiuSdHJsghoozPSo+2oG+E=
=8CEj
-----END PGP SIGNATURE-----

--TrGrrwHz9iYGKlIl--
