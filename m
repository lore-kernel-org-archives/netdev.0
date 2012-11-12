From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 1/1] isdn: Make CONFIG_ISDN depend on CONFIG_NETDEVICES
Date: Mon, 12 Nov 2012 18:08:09 +0100
Message-ID: <50A12CF9.7000608@imap.cc>
References: <1352282103-13665-1-git-send-email-lee.jones@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB344C93EC3BBAA095A4C37E3"
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: Lee Jones <lee.jones@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:54843 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751992Ab2KLRIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 12:08:12 -0500
In-Reply-To: <1352282103-13665-1-git-send-email-lee.jones@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB344C93EC3BBAA095A4C37E3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Am 07.11.2012 10:55, schrieb Lee Jones:
> It doesn't make much sense to enable ISDN services if you don't
> intend to connect to a network. Therefore insisting that ISDN
> depends on NETDEVICES seems logical.

Well, not quite. ISDN is (was?) also used for telephony applications
which could work just fine without network devices. But I guess not
many kernels will actually be built with CONFIG_NETDEVICES=3Dn, so the
inconvenience is small.

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)



--------------enigB344C93EC3BBAA095A4C37E3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAlChLPkACgkQMdB4Whm86/lndACfTtpdyYN/SwgtIfYCxV1kF0Qb
LS8AnAufcDUSDIliIjuu4X/MagMpcZJw
=WOqN
-----END PGP SIGNATURE-----

--------------enigB344C93EC3BBAA095A4C37E3--
