From: Harald Welte <laforge@netfilter.org>
Subject: Re: [netfilter-core] [NETFILTER] Apply IPsec to ipt_REJECT packets
Date: Wed, 24 Nov 2004 08:29:53 +0100
Message-ID: <20041124072953.GS19371@sunbeam.de.gnumonks.org>
References: <20041123084225.GA3514@gondor.apana.org.au> <41A37EC0.8010901@trash.net> <20041123211630.GA9805@gondor.apana.org.au> <41A3AF41.4010700@trash.net> <20041123221900.GA10099@gondor.apana.org.au> <41A3CD45.4080802@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/UvyDgxjlFfP/4zZ"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        coreteam@netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41A3CD45.4080802@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--/UvyDgxjlFfP/4zZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 24, 2004 at 12:52:37AM +0100, Patrick McHardy wrote:

> I would prefer something like this (based on your patch, untested).=20
> Currently
> ICMP packets are handled different than TCP packets, saddr is set to 0 for
> them if it is non-local, so they can't be source-routed properly. This pa=
tch
> also uses route_reverse for ICMP packets, properly sets fl->proto for out=
put
> routed packets and adds a call to xfrm_lookup for input routed packets.

Just a quick side note: Once we've found a final solution, please don't
forget to merge the changes to ip6t_REJECT in patch-o-matic.

> Regards
> Patrick
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--/UvyDgxjlFfP/4zZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBpDhwXaXGVTD0i/8RAnpIAJ9a2hlHV206EpSWsqfMWL8T4XiorwCeJ33f
LMgvjamQbrB0L62zmuf0ZZw=
=bI85
-----END PGP SIGNATURE-----

--/UvyDgxjlFfP/4zZ--
