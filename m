From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the ipsec-next tree with the net-next
 tree
Date: Thu, 9 Jan 2014 13:41:17 +1100
Message-ID: <20140109134117.41611cbfb87052212da67f03@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__9_Jan_2014_13_41_17_+1100_dMnYdPS_pv+MHWlp"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	Weilong Chen <chenweilong@huawei.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38097 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952AbaAIClY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 21:41:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__9_Jan_2014_13_41_17_+1100_dMnYdPS_pv+MHWlp
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Steffen,

Today's linux-next merge of the ipsec-next tree got a conflict in
net/xfrm/xfrm_policy.c between commits be7928d20bab ("net: xfrm:
xfrm_policy: fix inline not at beginning of declaration") and
da7c224b1baa ("net: xfrm: xfrm_policy: silence compiler warning") from
the net-next tree and commit 2f3ea9a95c58 ("xfrm: checkpatch erros with
inline keyword position") from the ipsec-next tree.

I fixed it up (I used the version from the net-next tree) and can carry
the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__9_Jan_2014_13_41_17_+1100_dMnYdPS_pv+MHWlp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSzgxRAAoJEMDTa8Ir7ZwV0ngP+wZLfmLbO1ufZxotLK1oFtqw
zeI2eM8f4We+8BicZSvseea/jBxjdvRAse8HKMioscet2v1HdcMgUY7NHaphsqRF
P4alnURnk5J6NuFp5MaDB9S2AKKpqLWWQ7lq0sjfZ9eLS0XpTiQeIPoDmV8Rq6+F
CfGCZCZSqy4ayF+t74QvoWYMuqL5fNA3PeRVNAT6GF2EQFD2bgI62vfK+HdaEMku
RTGgpqwh4s2cpuBC72v6ar6fM3R4YWh+S5SGmFybtHcmHrpr7ucCKWYekwRPcZOL
YGXt8DOPYvUGr7fmAwy4pOEyKf1eK3riX+ZMBG0QuUXlsZAC4SAtGPhh5ieVeyq6
7VjuiuAKL7L7o7feZhMrXApakdOowSPjHSAu4uzNg2OMff1Fqae8OoXkl9ZqJYvX
Jw8/rNcoseAk/B/OjhbnNF4aYTxOBDizv2ZjqXLAsg0utDOY8shRz0mjq+4nnr0v
hjw1/nyq/fbPrZLBQsFtLg0UNcsq37JF5lOdKpasP8SoE9SADFYYei6dDPTYJn+H
RjVUuwinWCpdNU8egDjf40g8Td+T5v+EfN24kSGfM88+zzlDLixZyDITGSIEWi7u
6aJennljunJkfDUuN3oTqNM3T9vXXPjbJIkfR9qijme6oRONAv0clj3CcvCq6Jdm
b4g02cENxUK4fxAzuayp
=gEOF
-----END PGP SIGNATURE-----

--Signature=_Thu__9_Jan_2014_13_41_17_+1100_dMnYdPS_pv+MHWlp--
