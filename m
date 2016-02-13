From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [net-next PATCH V2 0/3] net: mitigating kmem_cache free slowpath
Date: Sat, 13 Feb 2016 12:12:54 +0100
Message-ID: <56BF0FB6.5050905@imap.cc>
References: <20160207.142526.1252110536030712971.davem@davemloft.net>
 <20160208121328.8860.67014.stgit@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="xdXKd8MFNvl4kEeswtWbASbqC5ffCcIIa"
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, tom@herbertland.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, linux-mm@kvack.org,
	Christoph Lameter <cl@linux.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:47291 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750949AbcBMLNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2016 06:13:06 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 8965220319
	for <netdev@vger.kernel.org>; Sat, 13 Feb 2016 06:13:05 -0500 (EST)
In-Reply-To: <20160208121328.8860.67014.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xdXKd8MFNvl4kEeswtWbASbqC5ffCcIIa
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Jesper,

Am 08.02.2016 um 13:14 schrieb Jesper Dangaard Brouer:
> Introduce new API napi_consume_skb(), that hides/handles bulk freeing
> for the caller.  The drivers simply need to use this call when freeing
> SKBs in NAPI context, e.g. replacing their calles to dev_kfree_skb() /
> dev_consume_skb_any().

Would you mind adding a kerneldoc comment for the new API function?

Thanks,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--xdXKd8MFNvl4kEeswtWbASbqC5ffCcIIa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWvw/AAAoJEFPuqx0v+F+qs2gH/3Gr24ChcMolB8Yjjzf8Q/Vx
TSuaNglOS/fapAY3IF0imBDUxeEMNxnUIR3DQFF/SY83GwNpBGCzz+4Saf35vCGp
w77X55DlN4yWEgUctwu/2DxYw2cmb26pA2kBSHTseY6sqeuL1IobNHc6q7B4uda8
NP1+TOpT75KkzBWPaAKcOG01udCYXH469DYKoEhP1wlCN8klPXrvoCBs+1v1wMJE
J8q6LhvtWnDNUJf3SOQLCkwRhENxVFR0gvo2sDPZBgb4lVoE50/FNiRMIb/2eIow
IYvpcunL/E1WdxVK0GnoU4V62bSQGUM8YFZQVOyadPJ7IGUgt+3lU7W9eCuI654=
=X/MR
-----END PGP SIGNATURE-----

--xdXKd8MFNvl4kEeswtWbASbqC5ffCcIIa--
