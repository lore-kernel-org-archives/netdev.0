From: Alfredo Beaumont Sainz <jtbbesaa@bipt106.bi.ehu.es>
Subject: Re: Problems with Broadcom and Intel PRO/1000 cards
Date: Thu, 2 Jun 2005 16:11:42 +0200
Message-ID: <200506021611.54933.jtbbesaa@aintel.bi.ehu.es>
References: <200506021238.25615.jtbbesaa@aintel.bi.ehu.es> <d7mqpp$pnn$1@harrier.cohaesio.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1279143.OyKeIErFOt";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <d7mqpp$pnn$1@harrier.cohaesio.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1279143.OyKeIErFOt
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Og, 2005eko Ekaren 02a 13:34(e)an, Anders K. Pedersen(e)k idatzi zuen:
> Alfredo Beaumont Sainz wrote:
> > I've a dual opteron machine with an integrated dual Broadcom 5704
> > 10/100/1000 (tg3 driver) and an Intel PRO/1000 MT (e1000 driver). It
> > seems that I cannot make them work a Gbps. I've a crossover cable
> > connecting a interface of the Broadcom (eth1) with the Intel (eth2), but
> > they connect at 100Mbps:
> >
> > # /sbin/mii-tool -v
>
> mii-tool does not (yet) support more than 100 Mbit/s, so it will report
> a 1000 Mbit/s connection as only running 100 Mbit/s. Use ethtool for now.

Ouch, you are right. They are really working at 1000Mbit/s. I should have=20
checked that. They work with a crossover cable, but I still have problems w=
ith=20
the switch. I'll further investigate before posting again.

Thanks!
=2D-=20
Alfredo Beaumont. GPG: http://aintel.bi.ehu.es/~jtbbesaa/jtbbesaa.gpg.asc
Elektronika eta Telekomunikazioak Saila (Ingeniaritza Telematikoa)
Euskal Herriko Unibertsitatea, Bilbao (Basque Country). http://www.ehu.es

--nextPart1279143.OyKeIErFOt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBCnxOq6KTU/EgLc1ERAsbKAJ9U+j2OiPemLbu1oNp/t/T1ijHWDQCeLRho
mxzLFdj20GxHxb4LXD7z5pM=
=drCD
-----END PGP SIGNATURE-----

--nextPart1279143.OyKeIErFOt--
