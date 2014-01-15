From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Wed, 15 Jan 2014 02:43:36 +0000
Message-ID: <1389753816.3720.184.camel@deadeye.wl.decadent.org.uk>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	 <1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	 <20140113.115913.1269834557058575064.davem@davemloft.net>
	 <1389644256.31367.223.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1389646213.2025.159.camel@bwh-desktop.uk.level5networks.com>
	 <1389649061.31367.236.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1389749477.3720.173.camel@deadeye.wl.decadent.org.uk>
	 <1389752827.31367.314.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5bx/bWnsEEhdP3If3zor"
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45624 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752317AbaAOCnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 21:43:47 -0500
In-Reply-To: <1389752827.31367.314.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5bx/bWnsEEhdP3If3zor
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-01-14 at 18:27 -0800, Eric Dumazet wrote:
> On Wed, 2014-01-15 at 01:31 +0000, Ben Hutchings wrote:
>=20
> > When I investigated the scope of this for Debian, I tried sending a
> > 'packet of death' to a VM and actually triggered the lockup in the TX
> > path of the *host*, running Debian unstable with Linux 3.11.  I didn't
> > track down exactly why that was but I think that libvirt's default
> > networking configuration includes multiqueue devices that use flow
> > dissector.
>=20
> OK, I take that majority of debian hosts are running some VM then,
> nice to know, time to update my hosts and usages I guess.

I said that common configurations use flow dissector - not the majority.

> Anyway, current flow dissector needs care if we really use it in
> unprotected areas.
>=20
> Hostile packets can force flow dissection of MTU bytes,
> bringing host to abysmal performance.
[...]

Yes.  I think the number of times it can loop should be limited to some
small number.

Ben.

--=20
Ben Hutchings
Life is what happens to you while you're busy making other plans.
                                                               - John Lenno=
n

--=-5bx/bWnsEEhdP3If3zor
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUtX12Oe/yOyVhhEJAQoLeQ/+NBq7CR9OJYU44+QG2fhLFCViLe2A+BY7
aEO4znlr4ZpwOE70BoJHf5pgFymbq64lGIVUk9fCnt0nXVJtz/8t7cpBtHRH6/hR
q1xTrFT1QXEF5gTya2wspOEeEhwHEmEPQ0baLN/wEtloXn5+YoJwZwC7jvi749Jd
P8sGb1GcJBTFKVG5AaJrW6IzrF2s2++6hBkSJym2Xn6yNYMfXn2JkFF3psEvtYWZ
QyTM3ufHS8dBaGpA3CxoBarVXUR1phS/BAWRqmiK4RAioglYpwVqtgGnZvkSATAT
m3xTzENHRKl2DPk2W/SdSUx+4QueD9O2Nbo8m4X9pKy4eVWZUYlzCgG1BrIUwEyc
jm+c5Wq9uFrdesOTy5uMu2if6tSHZWxTRf21kx6lmL+vrIXAFboY0/35bO4kCdCY
I1X/uooR34Ozhn07up1F8zjnbi16Pq0niDG+RdCotlPC5VWsExy/hKS45HWhL+xW
GzzO3eR+rUPPv7/UcVDtuCJVw3AODgC6is32cHaqxiU/11QjqtTqHbjOzVPal2EV
S4w1ch+Nn42RteIMTRZNNgHwFq67y3QACuqcY7CbF3nj2JuR3/cYWYZF0lib9flk
WBFHvbXmDIN0Rc2Pnm2FAAoxgclE0BuymiPClk0MEDPjrxwplGB7rHkUPLo2Hj8M
FZBasFZHK9g=
=tLu6
-----END PGP SIGNATURE-----

--=-5bx/bWnsEEhdP3If3zor--
