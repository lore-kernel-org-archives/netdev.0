From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Tue, 26 Aug 2014 12:05:11 +1000
Message-ID: <20140826120511.5b5dabef@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/PUCpg+miztOfQP2ls2B2JY8"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:43259 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756909AbaHZCFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 22:05:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/PUCpg+miztOfQP2ls2B2JY8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

drivers/net/ethernet/marvell/mvneta.c: In function 'mvneta_skb_tx_csum':
drivers/net/ethernet/marvell/mvneta.c:1374:3: error: implicit declaration o=
f function 'vlan_get_protocol' [-Werror=3Dimplicit-function-declaration]
   __be16 l3_proto =3D vlan_get_protocol(skb);
   ^

Caused by commit 817dbfa5d1bc ("mvneta: Fix TSO and checksum for
non-acceleration vlan traffic").

I have reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/PUCpg+miztOfQP2ls2B2JY8
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJT++tcAAoJEMDTa8Ir7ZwVR6EP/jPO4JgHtVCOT6VtpS/mYOD0
PSabkz+gKkOHoVdIYT85ctaf/b3X30534Q1vsn8MMnIudwfSJRxLwkP8Wmsp7Eev
Tqbu4UQW1QJf+EN/WjBen8t4pROgRYek0Mk1vtY2BK3fa7G4CumhTEAr/GvpdlY8
nCt7Fs3s+GFvDuvCE7aDYBDd/zMynKEpL0vvaghdIqK8UbSdQINCVk3GIp5rqP/+
0vUjD4uc97s2TvbJpjTQ839rx3dfi3PJJX5rAjDXy4GwgKm4Bx9bF36AoTz0n/4M
ddaPLZ19BAM2f4MSLy8TSDA4BQNqXZLnTlJLYIb35SfHApjAm2wQkLYL8QwLpEVX
fKl66W44jHBqn2J0O2cnwP4xdtWiwuMnuw0t58O9o6wKUg8xdHK3A9SDiG8fNVFn
WgCT7xWb3VDRwodo2Pu8ot8zHZVH+91n5flINx4vLJmGWNhsMTgHPdplzi49DOWn
5h1Wn98JHLALyzl4VeTj/08C6xUBwwtghJ8666aw2qxB4SPGvUfFcx37sE0+8MMr
QeF1AOO9z45TwcY1YiNflHuy/7xhvdbM4vyg6iFv0wIcn+0akMrPeOm87Y5LQKU5
CLRIlY3zfgLUbELZFBGzThu7MElDHUr0h2GY2k0jKy7HDVcVRxxVLf266cINc09N
UH8T6APxQQFMppUsoVaQ
=xHJk
-----END PGP SIGNATURE-----

--Sig_/PUCpg+miztOfQP2ls2B2JY8--
