From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: ethtool NFC/ntuple API questions
Date: Wed, 20 Jan 2016 19:22:51 +0000
Message-ID: <1453317771.3734.68.camel@decadent.org.uk>
References: <569FBF9D.40002@solarflare.com>
	 <CAKgT0Ud1OprxqjYQC4NrFmRyhrG4x1G2=dWZEKwW866XAyW-eA@mail.gmail.com>
	 <1453313223.3734.63.camel@decadent.org.uk>
	 <569FDC04.9090509@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Y1PsgPdscmWjk/h1fspv"
Cc: netdev <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54111 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753426AbcATTXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 14:23:09 -0500
In-Reply-To: <569FDC04.9090509@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Y1PsgPdscmWjk/h1fspv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-01-20 at 19:12 +0000, Edward Cree wrote:
> Thanks both, it's making more sense now.
> One thing I'm still unclear about: why does struct ethtool_usrip4_spechav=
e
> the ip_ver field?=C2=A0=C2=A0The struct can't be extended to cover ipv6, =
because the
> address fields aren't big enough.=C2=A0=C2=A0So what's it for?

It's also defined to always have the same value and mask! =C2=A0It's a
design bug.

> Also, would it be appropriate to use struct in6_addr for IPv6 addresses, =
or
> should I use __be32[4]?

I think for consistency with the IPv4 structures it should be __be32[4].

Ben.

--=20
Ben Hutchings
The program is absolutely right; therefore, the computer must be wrong.
--=-Y1PsgPdscmWjk/h1fspv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVp/ei+e/yOyVhhEJAQr7XA/+Jl0CkFB3POhsAsTgp1is3ZMWl95qBiyF
HoiFr1kN30KBw6DoIW5kZOIDNxYS0D7IcSZgvcqZExoxpF2jKB4Oy2QYYuSmeGhT
Z1LCvrvOqLZL9oDtJ7Ea6uEiePLsy5QoGg7tAEUttdwAuFR9tvFBTwjltIz2ddd0
mNTAmbNUULNWmWuPVFszA/0hl2m6tptPtpcpG03imjLMrf1EEeKf30UYtyRNvwAO
eW1AlwJht97Xl8ofurEnR7ooGlb8FTXEHrejnbC7IB7NgAwt+vK9zXIY3nL2TF/V
1UfuFsvoAFnxdaQIy8eHLLPp+IC9do4Gmw+AD9KpK9Hrenw+IoA/4RaSQjGkvWfs
ZFt6uOtXwYgkQO898/6wQSW7WBciCcClyFExRdAzkR9SSulvsD4oh2bqThyAs4qz
VgnHp8tjx83JY6gQEqCCX/fxvdsveotXIFJ41l5M00sd2ZHppXWoQekQ7q7o6T2Z
yugNkL37Q7G4IcwzzwuaPdJ/yFnUqLb2g99xNy/zTBYa55oPyNVXJnmoto51dRHQ
6sOnfGCBQkA4Nnh5bJ+MZSbhMbD5PQwacleUd1kZv2PkOsdfF4euDqt0gvACSB4g
WJuSM+fcoXGV8hP4h3knCPfNNk7opIltvgG2C5Ce50uykRL9AI9xKq7hHXfTk8XQ
ZqTK+S8+zsU=
=HW1B
-----END PGP SIGNATURE-----

--=-Y1PsgPdscmWjk/h1fspv--
