From: Marek Lindner <mareklindner@neomailbox.ch>
Subject: Re: [B.A.T.M.A.N.] [PATCH 1/2] batman-adv: Delete unnecessary checks before the function call "kfree_skb"
Date: Sun, 22 Nov 2015 05:45:33 +0800
Message-ID: <2329415.lXFbWjXfj3__12853.976726956$1448143617$gmane$org@voltaire>
References: <5307CAA2.8060406@users.sourceforge.net> <56484502.8000206@users.sourceforge.net> <564845AE.8020008@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1573570.N95rHCmhjF"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	netdev@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>,
	kernel-janitors@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:32063 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759544AbbKUWGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Nov 2015 17:06:18 -0500
In-Reply-To: <564845AE.8020008@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1573570.N95rHCmhjF
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Sunday, November 15, 2015 09:43:26 SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sun, 15 Nov 2015 08:04:43 +0100
> 
> The kfree_skb() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the calls is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  net/batman-adv/main.c           | 2 +-
>  net/batman-adv/network-coding.c | 4 +---
>  net/batman-adv/send.c           | 3 +--
>  3 files changed, 3 insertions(+), 6 deletions(-)

Applied in revision 77d84a6.

Thanks,
Marek

--nextPart1573570.N95rHCmhjF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJWUOX9AAoJEFNVTo/uthzACYYH/A2iYbcxJ/MhlyXJslnVgmLf
BfzckoTCJQUH4mjopK/cZcvuAQT6HUTHXi2oBV5+58NRAwHAXg2zv1yDCtBuav+9
SPqYTWV4dNJb0cQFTuKbLXqXCGe/n1SlHgyvtttLgF3p0zjeNRQScqC5/2/urEBc
yZr8HmGofBVZGj8drzcL+deGari5o0z1r8RojzKv33E/IMv6sBZ5+I4EmNQGDLDg
zdWvHTRn/3MZGH4UsEw3HXVUVVOCeyjvAGEBORz63GZR42tM+0TCgHpo3Z7kTynE
WX2wFI/FRhoSxhHS3APzSUxQ/7o1MCuzNKDS430OYKVW/WrV8CP2jqVGrRUGwvQ=
=6jJq
-----END PGP SIGNATURE-----

--nextPart1573570.N95rHCmhjF--
