From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net-next v5 0/9] net: add support for IPv6 Segment Routing
Date: Thu, 10 Nov 2016 10:09:13 +0100
Message-ID: <58243939.5000200@uclouvain.be>
References: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be> <20161109.204058.1740541278564630528.davem@davemloft.net> <CAKD1Yr0fDFdDv9+S3i_rH6W6btEuvs9s-h33_N67iM4qrtDezQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="o8mRrhlIuK7X4LQbQWia0r9D1JIwLd295"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lorenzo Colitti <lorenzo@google.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59389 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753306AbcKJJHU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 04:07:20 -0500
In-Reply-To: <CAKD1Yr0fDFdDv9+S3i_rH6W6btEuvs9s-h33_N67iM4qrtDezQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--o8mRrhlIuK7X4LQbQWia0r9D1JIwLd295
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/10/2016 09:35 AM, Lorenzo Colitti wrote:
> Not sure how to fix this. The following makes IPv6 work again, but I
> suspect it mostly defeats the purpose of having SRH on by default:
>=20
> +#ifdef CONFIG_LWTUNNEL
>          err =3D seg6_iptunnel_init();
>          if (err)
>                  goto out_unregister_pernet;
> +#endif
>=20
> Enabling CONFIG_LWTUNNEL also makes IPv6 work again.
>=20
> The breakage was caught by the kernel test robot, but the message was
> not particularly scary:

Oops. The easiest fix I can think of is adding an option to
enable/disable seg6's LWT which would select CONFIG_LWTUNNEL. That would
still let the core SR processing be enabled by default.

Comments ?

David


--o8mRrhlIuK7X4LQbQWia0r9D1JIwLd295
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlgkOTkACgkQjbzn67sZ6AMRtwCfZSMB8TOZTCfyRATebe8nw0uw
5AEAoISbSDW0nlWX3/t4v41YbnInlYU3
=PtjP
-----END PGP SIGNATURE-----

--o8mRrhlIuK7X4LQbQWia0r9D1JIwLd295--
