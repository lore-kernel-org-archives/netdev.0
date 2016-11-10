From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net-next v5 0/9] net: add support for IPv6 Segment Routing
Date: Thu, 10 Nov 2016 10:26:47 +0100
Message-ID: <58243D57.2000805@uclouvain.be>
References: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be> <20161109.204058.1740541278564630528.davem@davemloft.net> <CAKD1Yr0fDFdDv9+S3i_rH6W6btEuvs9s-h33_N67iM4qrtDezQ@mail.gmail.com> <58243939.5000200@uclouvain.be> <CAKD1Yr1OGn_JS_REOL9g5gELf9s=VdGfebSrticF2=Vf-m5oKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="HJSC3uppbJfFJp3o5XEJrjWVVXH7vjCoJ"
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:42058 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753880AbcKJJYy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 04:24:54 -0500
In-Reply-To: <CAKD1Yr1OGn_JS_REOL9g5gELf9s=VdGfebSrticF2=Vf-m5oKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--HJSC3uppbJfFJp3o5XEJrjWVVXH7vjCoJ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/10/2016 10:14 AM, Lorenzo Colitti wrote:
> So you'd split SRH functionality in three parts? Core (default on),
> lwtunnel (default off) and inline?
>=20
> It seems to me that once you've done the work to enable the core code
> to work when CONFIG_LWTUNNEL is off, you can just enable/disable the
> LWT part of SRH depending on whether CONFIG_LWTUNNEL is compiled in or
> not. That might save you a config option.

That would be easier indeed, but then this behavior should be documented
somewhere: how the user would know that it has to enable CONFIG_LWTUNNEL =
?

David


--HJSC3uppbJfFJp3o5XEJrjWVVXH7vjCoJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlgkPVgACgkQjbzn67sZ6AN7cQCfRWV9HAnDrC2WLvLnKbIe62nz
zNwAn2MwJWF/36K0rIVSXGm785ZpgQSj
=Wr/9
-----END PGP SIGNATURE-----

--HJSC3uppbJfFJp3o5XEJrjWVVXH7vjCoJ--
