From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH iproute2 net] ip: lwtunnel: remove definition of
 __USE_KERNEL_IPV6_DEFS
Date: Mon, 15 May 2017 16:22:37 +0200
Message-ID: <72a522bf-9e39-d5a9-6fad-72d5411a6228@uclouvain.be>
References: <20170515111334.23805-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="j8n0toxK5iugRikdA0uL1hb5wx0KCuBlp"
Cc: <daniel@iogearbox.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:37731 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933222AbdEOOWF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 10:22:05 -0400
In-Reply-To: <20170515111334.23805-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--j8n0toxK5iugRikdA0uL1hb5wx0KCuBlp
Content-Type: multipart/mixed; boundary="oJHg6hHd9DwJnsEKErWVTthcxhFBnSGFb"
From: David Lebrun <david.lebrun@uclouvain.be>
To: netdev@vger.kernel.org
Cc: daniel@iogearbox.net
Message-ID: <72a522bf-9e39-d5a9-6fad-72d5411a6228@uclouvain.be>
Subject: Re: [PATCH iproute2 net] ip: lwtunnel: remove definition of
 __USE_KERNEL_IPV6_DEFS
References: <20170515111334.23805-1-david.lebrun@uclouvain.be>
In-Reply-To: <20170515111334.23805-1-david.lebrun@uclouvain.be>

--oJHg6hHd9DwJnsEKErWVTthcxhFBnSGFb
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 05/15/2017 01:13 PM, David Lebrun wrote:
> When __USE_KERNEL_IPV6_DEFS is set, netinet/in.h will not define struct=
ures
> such as in6_addr. This is useful when linux/in6.h is also included.
> However, older glibc versions do not support this switch.
>=20
> This patch allows iproute2 to still be compiled with older glibc versio=
ns,
> along with the kernel net-next patch that updates include/linux/seg6.h.=


Please disregard this patch, it's not the proper way to solve the issue.

David


--oJHg6hHd9DwJnsEKErWVTthcxhFBnSGFb--

--j8n0toxK5iugRikdA0uL1hb5wx0KCuBlp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQT8nTbQ2eQR5sQwCJ+NvOfruxnoAwUCWRm5rQAKCRCNvOfruxno
AzWfAJ4qzSCediSX6IUwrmdJHQlVDibp5ACeJ3ILhPQ8mAOwoWaS9B6pbHaMbBs=
=CllP
-----END PGP SIGNATURE-----

--j8n0toxK5iugRikdA0uL1hb5wx0KCuBlp--
