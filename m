From: Marek Lindner <mareklindner@neomailbox.ch>
Subject: Re: [B.A.T.M.A.N.] [PATCH 2/2] batman-adv: Less checks in batadv_tvlv_unicast_send()
Date: Sun, 22 Nov 2015 05:47:11 +0800
Message-ID: <9988401.mi5Gfk0igO__7567.96035352654$1448143266$gmane$org@voltaire>
References: <5307CAA2.8060406@users.sourceforge.net> <56484502.8000206@users.sourceforge.net> <5648463F.3070403@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart3115496.lf9YDrhiNn"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	netdev@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>,
	kernel-janitors@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:24878 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622AbbKUWAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Nov 2015 17:00:18 -0500
In-Reply-To: <5648463F.3070403@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3115496.lf9YDrhiNn
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Sunday, November 15, 2015 09:45:51 SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sun, 15 Nov 2015 09:00:42 +0100
> 
> * Let us return directly if a call of the batadv_orig_hash_find() function
>   returned a null pointer.
> 
> * Omit the initialisation for the variable "skb" at the beginning.
> 
> * Replace an assignment by a call of the kfree_skb() function
>   and delete the affected variable "ret" then.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  net/batman-adv/main.c | 15 +++++----------
>  1 file changed, 5 insertions(+), 10 deletions(-)

Applied in revision 5a878b8.

Thanks,
Marek

--nextPart3115496.lf9YDrhiNn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJWUOZfAAoJEFNVTo/uthzAmIIIAIhojBp2a/my4W/0Q1Q5mhMr
ZlWxOIdgKhWPsYJ/OGPNEgpLHa543ItCCyiF0lf4N3NUEvhCoMmLJhOWqS82KoUM
X7oxaBJe4hjIOWkNSozWWYvERt+FlBUBUOQyWMxoEmnRvYcdyRG0DuB1s1tyWu88
1KqGJY8n1a8ogQim3sBCsmMNZyF33W/5t26cyogrZjiKwheA8K0BX92pjjgxY/0J
OzOhCNHn0O+bI3B/n9teKM80ZWbp74ffiChHl/v+Nf/K2U2fySiHnaRSSb7z/YjG
meknJjGKc51xb+RkAt8oVtPnj/hYv1IS9PL0vo9C+fNiqrRytOs1jFP7XJ8yIyM=
=Wl4b
-----END PGP SIGNATURE-----

--nextPart3115496.lf9YDrhiNn--
