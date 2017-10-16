From: Pavlos Parissis <pavlos.parissis@gmail.com>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Mon, 16 Oct 2017 13:20:19 +0200
Message-ID: <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com>
References: <1507121766.30720.4.camel@cohaesio.com>
 <CAKgT0UfAqzuEbFA_hs8f4goL2hTMqeJ5no2sAc8NO_KJO120tA@mail.gmail.com>
 <1507180753.20182.8.camel@cohaesio.com>
 <227d17ae-b040-07d0-3c57-e9acd1a3b5b4@itcare.pl>
 <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl>
 <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="C4L1K8cRxUJe7jGKq0rR9DKg9WDhXeG3J"
Cc: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
        =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:44644 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751501AbdJPLUV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 07:20:21 -0400
Received: by mail-wm0-f49.google.com with SMTP id 196so4506819wma.1
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 04:20:21 -0700 (PDT)
In-Reply-To: <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--C4L1K8cRxUJe7jGKq0rR9DKg9WDhXeG3J
Content-Type: multipart/mixed; boundary="ICpSSp2kicCL22xx8pfFQ8fximn5LXbhc";
 protected-headers="v1"
From: Pavlos Parissis <pavlos.parissis@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
 =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Cc: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
 "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
Message-ID: <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
References: <1507121766.30720.4.camel@cohaesio.com>
 <CAKgT0UfAqzuEbFA_hs8f4goL2hTMqeJ5no2sAc8NO_KJO120tA@mail.gmail.com>
 <1507180753.20182.8.camel@cohaesio.com>
 <227d17ae-b040-07d0-3c57-e9acd1a3b5b4@itcare.pl>
 <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl>
 <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
In-Reply-To: <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>

--ICpSSp2kicCL22xx8pfFQ8fximn5LXbhc
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

On 15/10/2017 02:58 =CF=80=CE=BC, Alexander Duyck wrote:
> Hi Pawel,
>=20
> To clarify is that Dave Miller's tree or Linus's that you are talking
> about? If it is Dave's tree how long ago was it you pulled it since I
> think the fix was just pushed by Jeff Kirsher a few days ago.
>=20
> The issue should be fixed in the following commit:
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/dr=
ivers/net/ethernet/intel/i40e/i40e_txrx.c?id=3D2b9478ffc550f17c6cd8c69057=
234e91150f5972
>=20


Do you know when it is going to be available on net-next and linux-stable=
 repos?

Cheers,
Pavlos



--ICpSSp2kicCL22xx8pfFQ8fximn5LXbhc--

--C4L1K8cRxUJe7jGKq0rR9DKg9WDhXeG3J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEHZDZK6DBu+YUj6+dg/yS2h9xdrkFAlnklfMACgkQg/yS2h9x
drkHKQ/+JAi0A5eStHNtrdSTXVMRmk/p1LmDWyfPqpVVHPgBa/zcaDhKLZOD3TEw
Q1zb5qq1oG6oXJHml6JpjB1ABtVFJwZ2reFsTbxQCfRWWLdwNsenKgw79xjP7+1G
YZsUevSBq3q/D1YlYKxb+hEAInXyVKoQKgQFrCtgFalGcTp/WSxIy5Juaw8J4swa
WTgDBw6Asc4gvruw6EMgf/UPKdwEQs2jTMbl5qpfL2AJMXwWxRHgDf5DkOzMx189
8poho7pebrnWavJqdt2ha8HJS2PUt3w9fhugtIcgLn5akZ6VPtOUtbd6atm8+DM8
Ljmf9BOUbPmMCpQFx+2QdUt7+ZHeKWS/Gh4Ti6cm2lrWp4+VS5/jA8HLd/htvsef
0Y/JdlrjtIQQNq2HJ8QHnjLm/Y1PwBrK0hjIMK+p+tYxGgCC7XC17GRIe9psZJhN
DAuB7NVHpvoyrizvhfZ/b6xrVIi4ZOq1/LMKSLsY95yADfiJG/46iJ2md/zaICxY
SKhIVZvJuPdy0KaZzm6zCjRmPgxJ27/NmhJyqdYTpgj4sCLHxdh3nbX24VivGDTD
w6n7ErhkJWla5YgP8pHJFHzvbtWMRWGCXZpqjYlJARd8xNwrVfwGFFA4PRZdN7OD
XeOlL1tJr53J2JAF7ZbQT0aCy1cGTijoWXG4QHnD5qPfeaOo+Lo=
=453Z
-----END PGP SIGNATURE-----

--C4L1K8cRxUJe7jGKq0rR9DKg9WDhXeG3J--
