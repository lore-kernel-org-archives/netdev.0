From: Alexander Samad <alex@samad.com.au>
Subject: Re: [RFC, PATCH 4/5]: netfilter+ipsec - policy lookup
Date: Wed, 24 Mar 2004 13:15:14 +1100
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040324021514.GM3387@samad.com.au>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF17.8090907@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="p7S+EREVcBHk3zUG"
Cc: "David S. Miller" <davem@redhat.com>, herbert@gondor.apana.org.au,
	netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4059CF17.8090907@trash.net>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--p7S+EREVcBHk3zUG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi

Think their might be a problem with this patch.

Potientially a packet could traverse the pre, forward and the post
routing, at which point it can be SNAT'ed or MASQ'ed and then re
injected into route_me_harder.  This potiential could allow packets to
be rerouted based on the new src/dst addresses differently to the intail
packet but this new packet doesn't traverse any of the chains with the
new information.

Alex

On Thu, Mar 18, 2004 at 05:32:23PM +0100, Patrick McHardy wrote:
> This patch adds policy lookups to ip_route_me_harder and makes NAT
> reroute for any change that affects route/policy lookups.
>=20



--p7S+EREVcBHk3zUG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAYO8ykZz88chpJ2MRAnXEAJkBiPiIlnQLPt511knU2+HjH/KpRwCfd50D
2ieGoF71hkk3fgK4SXT4/zg=
=jqBS
-----END PGP SIGNATURE-----

--p7S+EREVcBHk3zUG--
