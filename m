From: Henrik Nordstrom <henrik@henriknordstrom.net>
Subject: Re: [tproxy] udp + tproxy
Date: Thu, 13 Nov 2008 09:44:54 +0100
Message-ID: <1226565894.13986.5.camel@henriknordstrom.net>
References: <1226490030.31896.12.camel@sysandrey.icomswg.local>
	 <20081112185910.GA1793@sch.bme.hu>
	 <1226518030.10667.68.camel@bzorp.balabit>
	 <alpine.LNX.1.10.0811130815300.8076@fbirervta.pbzchgretzou.qr>
	 <1226561154.15193.10.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Im4PezwuqXRq7jk6G0xp"
Cc: Jan Engelhardt <jengelh@medozas.de>,
	KOVACS Krisztian <hidden@sch.bme.hu>,
	Andrey Luzgin <andrey@icomsw.com>, tproxy@lists.balabit.hu,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1226561154.15193.10.camel@bzorp.balabit>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Im4PezwuqXRq7jk6G0xp
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On tor, 2008-11-13 at 08:25 +0100, Balazs Scheidler wrote:

> PS: I was talking to Patrick McHardy whether to send the udp_accept()
> patch for kernel inclusion, he said it might be worth trying, however he
> was not completely sure it'd be integrated. So I didn't push it so far.

I second this, but also think that it will see some initial resistance.

I guess the main complaint (assuming code is in good shale) will be that
UDP does not have any sender verification, which means it's very easy to
flood the kernel with UDP "connection requests". But on the other hand
there is also no SYN_RECV or FIN_WAIT/TIME_WAIT states which may hold up
things beyond CPU processing speed so this is not by far as big problem
to deal with as in the TCP case..

Regards
Henrik

--=-Im4PezwuqXRq7jk6G0xp
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iQCVAwUASRvpA0NPQ5Kbx8daAQKPJwP/TgTUSTztlsJBJKE8aZY1+9vtsUzS2Y1H
qQ23pkO1A8SHO4UzuhSiU/HTsjYn7qZbgACFuwAlygrmUyQmPd8oR83c4aWaU579
NtRftSnM55+g0WnsuctLkMr2MLQLnsB7LARzACalMpx4S9Twh1PRAazqnVDDwFfJ
dibu/FeAiFE=
=vrTO
-----END PGP SIGNATURE-----

--=-Im4PezwuqXRq7jk6G0xp--

