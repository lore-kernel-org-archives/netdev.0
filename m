From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] i40e: skb->xmit_more support
Date: Tue, 07 Oct 2014 21:02:04 -0700
Message-ID: <1412740924.2295.35.camel@jtkirshe-mobl>
References: <1412713823.11091.166.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141007.163730.2221137596344407031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-T524RJdTRNhCHKnwlGMX"
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, dborkman@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24408 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754169AbaJHECH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2014 00:02:07 -0400
In-Reply-To: <20141007.163730.2221137596344407031.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-T524RJdTRNhCHKnwlGMX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-10-07 at 16:37 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 07 Oct 2014 13:30:23 -0700
>=20
> > From: Eric Dumazet <edumazet@google.com>
> >=20
> > Support skb->xmit_more in i40e is straightforward : we need to move
> > around i40e_maybe_stop_tx() call to correctly test netif_xmit_stopped()
> > before taking the decision to not kick the NIC.
> >=20
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>=20
> Intel folks, if I could get a quick review of this that would be great.
>=20
> Thanks.

Working on it, let you know tomorrow.

--=-T524RJdTRNhCHKnwlGMX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUNLc9AAoJEOVv75VaS+3OhaUP/0O8FMzniCGHKeXrm+W6b410
su1aP+e4IPeGLPmEbRnppvwTKdMDs0UxunTWy1Uyk6Qj8qSB4NOXNZkHPtZdz0Lg
IWGfNjDASBRw0Vmk263RUBQvcXkPMN9jSs5ql+fwSohSoUV9yyTv2MtVOM6r0NpD
wPo6ScLqKP3l2KmFwEAC15ZIrL25Nlf5SKhTuJgURZ9ANHIa1gVMJvIqngGmENZ0
URAafP/V7zUH6CMNXUl0jtKICRZwlfocLm5YBb8TWkpRdHXctpJTg682HBytV9OI
q/GWXcOu6QQ1IswkUIX7/jSKx25XgsRP3Nh+kNJhgZ0jdCVrzgfWCEnrwRZK2KvS
EgQAJ60dgTSIRcvEScRd0GhocebpKDPQE84dBG2nmKFKm6tYCsgWVeJlfQfEa1nX
e6GJPhLZq5QJQ8VkXC4UJs2/51F9pGEQuzNn9xFs4cGaUXIzG73UN8tBNuRt/ffM
A86p4jXvw65uFPQsmTHAORFzGDiGLSZCPtRJVWMm8I0/EqShsEP0W359rSlVWdiw
40B8F1Ea5iwIhR5+yRdr3KJSxPGgVEhTtUYe3iadJNNXhRxdzhnX410lVtMeHi7T
mPlr1cHQQwP5bZJX/S9OlQMvH6wrXyaBQftpypO2eZbYKM2kFVsxan2v7O7oOCTA
B1eArfi6URSHBqGTZVef
=hltv
-----END PGP SIGNATURE-----

--=-T524RJdTRNhCHKnwlGMX--
