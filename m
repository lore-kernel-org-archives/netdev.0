From: Marek Lindner <mareklindner@neomailbox.ch>
Subject: Re: [B.A.T.M.A.N.] [PATCH 1/3] batman-adv: Delete an unnecessary check before the function call "batadv_softif_vlan_free_ref"
Date: Sun, 22 Nov 2015 05:48:34 +0800
Message-ID: <1654342.xzdxStlkQC__32393.3846237653$1448143617$gmane$org@voltaire>
References: <5307CAA2.8060406@users.sourceforge.net> <56391CF7.9080400@users.sourceforge.net> <56391EAA.2060002@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2885958.OeX6xKt5oC"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	netdev@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>,
	kernel-janitors@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:38389 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742AbbKUWFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Nov 2015 17:05:50 -0500
In-Reply-To: <56391EAA.2060002@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2885958.OeX6xKt5oC
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Tuesday, November 03, 2015 21:52:58 SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Tue, 3 Nov 2015 19:20:34 +0100
> 
> The batadv_softif_vlan_free_ref() function tests whether its argument is
> NULL and then returns immediately. Thus the test around the call is not
> needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  net/batman-adv/translation-table.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)

Applied in revision bbcbe0f.

Thanks,
Marek

--nextPart2885958.OeX6xKt5oC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJWUOayAAoJEFNVTo/uthzAkjsH/jVuyf4Ouw89Isf/n3xjAKOT
b6GzZR66BrYCQeizuq/ZvxiIyqbM2J+rv2JrsO0Bz1kVqC3TJMC+JGvR6k7YWkBK
VDgWOs2d4FTlu+XIk6Wn5sd5C+5a+xcKwxx0FLifM+9DejfdLPoQqDJx+P7OXjFA
ddzXEaW3JqoTc5wceXDGKGcnt/8zlvAUWjxIhs3tYeE4Uc+VbU0kJLZFORIOt9O4
5lWbdKNVoCU76A+NmxjflJX1wvi64gi5oikJrfVPJu2dCAAySSV37vG3uaaLanLU
Hs+nEQE9IqVoxTtXmNGChZ4rqvYvHJtgoUzmnBcluzHq7CRIfrEcGMpsqYmeU1c=
=mmCS
-----END PGP SIGNATURE-----

--nextPart2885958.OeX6xKt5oC--
