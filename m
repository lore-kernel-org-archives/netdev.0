From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net-next v2] ipv6: sr: fix IPv6 initialization failure
 without lwtunnels
Date: Tue, 15 Nov 2016 11:17:20 +0100
Message-ID: <582AE0B0.60006@uclouvain.be>
References: <CAKD1Yr0fDFdDv9+S3i_rH6W6btEuvs9s-h33_N67iM4qrtDezQ@mail.gmail.com>        <1478780813-20005-1-git-send-email-david.lebrun@uclouvain.be>        <20161113.002055.1386089188095640295.davem@davemloft.net> <20161113.002348.81553025732356797.davem@davemloft.net> <5828C619.2020008@uclouvain.be> <5829C89B.7010405@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="4m6HOjo7fG7goEvo7w5QMd9Newmstunse"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <lorenzo@google.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:34670 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941383AbcKOKP3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 05:15:29 -0500
In-Reply-To: <5829C89B.7010405@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--4m6HOjo7fG7goEvo7w5QMd9Newmstunse
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/14/2016 03:22 PM, Roopa Prabhu wrote:
> I prefer option b). most LWTUNNEL encaps are done this way.
>=20
> seg6 and seg6_iptunnel is new segment routing code and can be under
> CONFIG_IPV6_SEG6 which depends on CONFIG_LWTUNNEL and CONFIG_IPV6.
> CONFIG_IPV6_SEG6_HMAC could then depend on CONFIG_IPV6_SEG6

Will do that, thanks

David


--4m6HOjo7fG7goEvo7w5QMd9Newmstunse
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlgq4LAACgkQjbzn67sZ6ANHjgCgiP1e1jCVz8Rf/Ivneh2q8xX3
22gAniLqFPrqNhbWbfXVTX0aQWDaYYtz
=JxTv
-----END PGP SIGNATURE-----

--4m6HOjo7fG7goEvo7w5QMd9Newmstunse--
