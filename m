From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [patch/RFC]: Asynchronous IPsec processing benchmark.
Date: Tue, 03 May 2005 17:38:27 +0400
Message-ID: <1115127507.3414.58.camel@uganda>
References: <20050429144103.A23268@2ka.mipt.ru>
	 <20050503095312.GA29788@gondor.apana.org.au>
	 <1115115502.3414.22.camel@uganda>
	 <20050503101447.GA29973@gondor.apana.org.au>
	 <1115116295.3414.30.camel@uganda>
	 <20050503102929.GA30097@gondor.apana.org.au>
	 <1115117728.3414.48.camel@uganda>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-FFK2WSC8sADObNy6J1+q"
Cc: netdev@oss.sgi.com, Patrick McHardy <kaber@trash.net>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1115117728.3414.48.camel@uganda>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-FFK2WSC8sADObNy6J1+q
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Here are some numbers:

./netperf -l 60 -H gw -t TCP_STREAM -i 10,2 -I 99,5 -- -m 4096 -s 57344
-S 57344

TCP STREAM TEST to gw : +/-2.5% @ 99% conf.

async-ipsec, 10^6bits/sec:  35.42
 sync-ipsec, 10^6bits/sec:  37.11

So even with existing timer deferring it is not noticebly slower [about
4%].

And I think that benefits it provides definitely cost that price and=20
compile time option.

--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-FFK2WSC8sADObNy6J1+q
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCd37TIKTPhE+8wY0RAho5AJ9rMXgXW4qUErGFYBfH1nLZWVDxxwCdH3ZZ
n1R13gy6YosPvqaXG4XfhhQ=
=dmqb
-----END PGP SIGNATURE-----

--=-FFK2WSC8sADObNy6J1+q--
