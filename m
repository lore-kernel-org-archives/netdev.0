From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Mon, 20 May 2013 14:14:49 +1000
Message-ID: <20130520141449.d6095c96c8fa031839ecf4db@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__20_May_2013_14_14_49_+1000_eQIm6cyI.OORVjct"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:44517 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695Ab3ETEOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 00:14:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__20_May_2013_14_14_49_+1000_eQIm6cyI.OORVjct
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
arch/x86/net/bpf_jit_comp.c between commit 650c8496702f ("x86:
bpf_jit_comp: can call module_free() from any context") from the net-next
tree and commit "bpf: add comments explaining the schedule_work()
operation" from the akpm tree.

The former means that the latter is no longer needed, so I used the
former and can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__20_May_2013_14_14_49_+1000_eQIm6cyI.OORVjct
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRmaM5AAoJEECxmPOUX5FEWTIP/3xvcPKoNc+1KzVxIOqPYACY
uRMi8t3HrEhH+IYE2zkZeEpg7W6wJXz7rCiqyIJRCs86xwuT25wVc1pxuShRU3Pk
w/q6OLH/mWxdG44tmHG90SqG+FelxE/VyNQRs0eyVDQRYJHgnx5oRJIZGkcxXfMN
DS3LwyZaXghrF3zuS7bgY3oojnzUCVEDnsh0ycUCjvmwP2DvNRjdl4kQr1K2w0k4
TbXq2IxxkRgSxZLM84cHJtAuvCrZUJHSV0dW0P3a99mJ1W72z99NkzCoYHq6MRZc
RWW73lsFmBda8rzwSY+Ssb8BwJ3aHCwcsbh8MP3hynzcPd8UA4wLZX/xs6oqLm5q
F4C48yFIEMGjSatNwxB7bZCm4jrkUoSA4i9hHv64+EtpJCKg/HU0JOxDzht/GCtk
ieNi7OG45jr3tKJ1Uq9m40qwp732gttnAw7mleeGvZFklyzab6O8eDJWD1iDPc9v
cSVPdtXSvmxxbeuiNuGevBd94pb0uGXj6UL/wFZiw/QgoqeaT81eMeuLNBD+AH+j
qmBkBvjWllESZSJECIA3bcAfcy8fFByqi7r1AyrdO23ADjHqKByVwiCYC4EBV3tg
g3Vs2kZBxf1qv5p89ld3wkGj+GUXHiARLUWbf4dHJYI/OkS1NlQkOijZmvX4HIwk
dxxo8W3xBubdpskXHG3r
=je9p
-----END PGP SIGNATURE-----

--Signature=_Mon__20_May_2013_14_14_49_+1000_eQIm6cyI.OORVjct--
