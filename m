From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net-next v5 0/9] net: add support for IPv6 Segment Routing
Date: Thu, 10 Nov 2016 09:19:28 +0100
Message-ID: <58242D90.4020309@uclouvain.be>
References: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be> <20161109.204058.1740541278564630528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="k8kWBgF7c1FGd0SfnTe21VnafaX6a6JB2"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:52159 "EHLO
        smtp3.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752563AbcKJIRh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 03:17:37 -0500
In-Reply-To: <20161109.204058.1740541278564630528.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--k8kWBgF7c1FGd0SfnTe21VnafaX6a6JB2
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 11/10/2016 02:40 AM, David Miller wrote:
> Series applied, but I wonder if using a Kconfig knob for the INLINE thi=
ng
> is overkill.

Thanks :)

The Kconfig knob was a response to the concern that direct header
insertion breaks things. Moreover, if the IETF decides that direct
header insertion must be explicitely banned in rfc2460bis, then at least
we do not have a non-RFC compliant behavior by default.

David


--k8kWBgF7c1FGd0SfnTe21VnafaX6a6JB2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlgkLZAACgkQjbzn67sZ6AO9MgCcDBOieQIvgQuTtKivpVGF1fyN
5LMAoIyR9YqGIKjrQ2ZLM3GFrcRePVEC
=1Msn
-----END PGP SIGNATURE-----

--k8kWBgF7c1FGd0SfnTe21VnafaX6a6JB2--
