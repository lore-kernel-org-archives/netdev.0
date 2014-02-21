From: "Zimmermann, Alexander" <Alexander.Zimmermann@netapp.com>
Subject: Re: [PATCH 1/1] TCP NewCWV for Linux
Date: Fri, 21 Feb 2014 08:16:36 +0000
Message-ID: <4C5CF805-D1A6-4DC1-B48F-F3D145C54C58@netapp.com>
References: <bbf79368e5d6514fbe6704a77b473407.squirrel@blake.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_513FCD40-5408-48CF-ABCE-077EACEDB085";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ziaul.hossain@abdn.ac.uk" <ziaul.hossain@abdn.ac.uk>,
	Fairhurst Gorry <gorry@erg.abdn.ac.uk>
To: "raffaello@erg.abdn.ac.uk" <raffaello@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.netapp.com ([216.240.18.38]:15201 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753726AbaBUI2l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Feb 2014 03:28:41 -0500
In-Reply-To: <bbf79368e5d6514fbe6704a77b473407.squirrel@blake.erg.abdn.ac.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_513FCD40-5408-48CF-ABCE-077EACEDB085
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

Hi,

Am 20.02.2014 um 20:28 schrieb Raffaello@erg.abdn.ac.uk:

> Hi,
>=20
> This is a patch for newcwv a TCP sender-side modification,
> currently a work item at TCPM (TCP Maintenance and Minor extensions)
> at the IETF:
>=20
> http://tools.ietf.org/search/draft-ietf-tcpm-newcwv-05
>=20
> newcwv aims to supersede CWV (RFC2861) to provide better
> congestion control for rate-limited applications that use TCP.
>=20
> We implemented it as a module that uses tcp_congestion_ops.

This implies that we cannot use NewCWV w/ any other CC algo than
NewReno. Please correct me if I=92m wrong, but this is not what we
(finally) would like to have. The NewCWV implementation should be
CC independent.

Alex=20

> The main changes are in "cong_avoid" before Reno cwnd control
> and at the start and end of Fast Retransmit:
>=20
> 1) Before Reno algorithm we estimate at each ACK our pipeACK
> (update_pipeack) and decide to increase or not cwnd based on pipeack.
>=20
> 2) At the start of FR we reset cwnd based on pipeACK, while
> at the end we further reduce pipeACK by the number of retransmissions.
>=20
> I posted it here for you consideration to be included in net-next.
>=20
> ---


--Apple-Mail=_513FCD40-5408-48CF-ABCE-077EACEDB085
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAlMHC2EACgkQdyiq39b9uS6J8wCffEe/30Y5dEq/I0Jl8BlWhuQ9
zDYAoIi8rwqYMLvYuzE3czBwW80dHVEO
=Zg8o
-----END PGP SIGNATURE-----

--Apple-Mail=_513FCD40-5408-48CF-ABCE-077EACEDB085--
