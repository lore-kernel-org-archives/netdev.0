From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH v2] ipv6: sr: fix get_srh() to comply with IPv6 standard
 "RFC 8200"
Date: Wed, 30 Aug 2017 12:24:04 +0200
Message-ID: <d4187569-a9ef-2525-becc-b3b81090db4c@uclouvain.be>
References: <1504083037-1605-1-git-send-email-amsalam20@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="IFuMCiPlQXlJF29IfTfxkvLCKJr3cegvV"
Cc: <netdev@vger.kernel.org>
To: Ahmed Abdelsalam <amsalam20@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:35832 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751319AbdH3KXd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 06:23:33 -0400
In-Reply-To: <1504083037-1605-1-git-send-email-amsalam20@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--IFuMCiPlQXlJF29IfTfxkvLCKJr3cegvV
Content-Type: multipart/mixed; boundary="ibK47astqljOvrOuJgRJomoiiH6qD9fOE"
From: David Lebrun <david.lebrun@uclouvain.be>
To: Ahmed Abdelsalam <amsalam20@gmail.com>, davem@davemloft.net
Cc: netdev@vger.kernel.org
Message-ID: <d4187569-a9ef-2525-becc-b3b81090db4c@uclouvain.be>
Subject: Re: [PATCH v2] ipv6: sr: fix get_srh() to comply with IPv6 standard
 "RFC 8200"
References: <1504083037-1605-1-git-send-email-amsalam20@gmail.com>
In-Reply-To: <1504083037-1605-1-git-send-email-amsalam20@gmail.com>

--ibK47astqljOvrOuJgRJomoiiH6qD9fOE
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 08/30/2017 10:50 AM, Ahmed Abdelsalam wrote:
> This patch fixes the get_srh(), so it gets the segment routing header
> regardless of its position in the chain of the extension headers in IPv=
6
> packet, and makes sure that the IPv6 routing extension header is of Typ=
e 4.
>=20
> Signed-off-by: Ahmed Abdelsalam <amsalam20@gmail.com>

Note that this patch applies to net-next.

Acked-by: David Lebrun <david.lebrun@uclouvain.be>


--ibK47astqljOvrOuJgRJomoiiH6qD9fOE--

--IFuMCiPlQXlJF29IfTfxkvLCKJr3cegvV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQT8nTbQ2eQR5sQwCJ+NvOfruxnoAwUCWaaSRwAKCRCNvOfruxno
A5kbAKCEOHpj84dHDgub1UeKJQQkfM+iUwCdEVTujyHaxmAEZTvySr/tS1zDFGU=
=GL4I
-----END PGP SIGNATURE-----

--IFuMCiPlQXlJF29IfTfxkvLCKJr3cegvV--
