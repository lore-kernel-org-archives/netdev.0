From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [PATCH] Even Batman should not dereference NULL pointers
Date: Thu, 13 Jan 2011 22:13:15 +0100
Message-ID: <201101132213.18503.sven@narfation.org>
References: <alpine.LNX.2.00.1101132146400.11347@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart12825553.O9jQGzAFVI";
  protocol="application/pgp-signature";
  micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36199 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756915Ab1AMVNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jan 2011 16:13:22 -0500
In-Reply-To: <alpine.LNX.2.00.1101132146400.11347@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart12825553.O9jQGzAFVI
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Thursday 13 January 2011 21:53:38 Jesper Juhl wrote:
> There's a problem in net/batman-adv/unicast.c::frag_send_skb().
> dev_alloc_skb() allocates memory and may fail, thus returning NULL. If
> this happens we'll pass a NULL pointer on to skb_split() which in turn
> hands it to skb_split_inside_header() from where it gets passed to
> skb_put() that lets skb_tail_pointer() play with it and that function
> dereferences it. And thus the bat dies.
>=20
> While I was at it I also moved the call to dev_alloc_skb() above the
> assignment to 'unicast_packet' since there's no reason to do that
> assignment if the memory allocation fails.

Applied

Thanks,
	Sven

--nextPart12825553.O9jQGzAFVI
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAABCgAGBQJNL2rsAAoJEF2HCgfBJntG0DIQAIbD6U+6ITHA4PD08pn2Vq6K
3iioaSryDTDa+a9nEz6T3vox64dSLTQVC4fzXkFQW+FGUX3QzGVCh4cpNPjgSpoI
gL9+DK5OahV4TZVSy2yjGDX230H7GjlwXRycTuALx0Xk3pS/ElAjoJc9W79rN9xC
P7mBbFEskPO4L8rkcTSRWGPlWoSHo++q8nWHmDN+5HitmyfTMFBFiQN0IRxQh62+
gM1usbAIPOLoqwer3udI/tw+J2nrkmVFDtmFGAzgznKMqv1++hqUrtib2603yzZs
0NNOLOvWc0zyHtwoBK9jmEvD2hrqiB/pvjQWz37JZ5Pi7M6eXaCKPZgNPtrJj1xT
kqFjDdNsUK72RNNJqrV2Kd+3LPIsofwH6EJ9XxvIBJzlJXhUJmTn6zpl94UtoEQc
q/xsqPMTHm1E4kM8dcJELXSFDsPlFEzu3p33M2+/FNIxLFlb8nUKB6GDVxo2PGYM
NG0zT341rzDNmbzUshcPolWR+h69+6De0HPQvsDBbzqtTLQV1IxGaTzvkNHPCaSY
F/73q3QJsCIbpwy9kVo5j4G4m17IicGIIXUzIUqMacGYsspHE7/obzEl7MWmlC08
slNxmCrNzfSMeyFF4kmPzeuY//tH9SfjL7iFJ5brU6/nCq5+Kf0tXdLsrTML7PnE
ex3OQ/zyZp1EcKcjYjmJ
=heoP
-----END PGP SIGNATURE-----

--nextPart12825553.O9jQGzAFVI--
