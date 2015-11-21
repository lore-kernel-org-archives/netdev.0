From: Marek Lindner <mareklindner@neomailbox.ch>
Subject: Re: [B.A.T.M.A.N.] [PATCH 2/3] batman-adv: Split a condition check
Date: Sun, 22 Nov 2015 05:51:04 +0800
Message-ID: <2723284.fvSBmu6aJ3__2843.14265377379$1448142741$gmane$org@voltaire>
References: <5307CAA2.8060406@users.sourceforge.net> <56391CF7.9080400@users.sourceforge.net> <56391F0B.2060102@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart5154744.fNLkcmSmS2"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	netdev@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>,
	kernel-janitors@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:28458 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbbKUVvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Nov 2015 16:51:14 -0500
In-Reply-To: <56391F0B.2060102@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart5154744.fNLkcmSmS2
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Tuesday, November 03, 2015 21:54:35 SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Tue, 3 Nov 2015 20:41:02 +0100
> 
> Let us split a check for a condition at the beginning of the
> batadv_is_ap_isolated() function so that a direct return can be performed
> in this function if the variable "vlan" contained a null pointer.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  net/batman-adv/translation-table.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)

Applied in revision b1199c6.

Thanks,
Marek

--nextPart5154744.fNLkcmSmS2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJWUOdIAAoJEFNVTo/uthzAH6MH/1ZRFtHupThwVXcBfnoqGgUY
qgd9VHY6TX1BEbSF79nydp8bqjIES8yXE8ltBXCwy3ixgkomZyxNyqnAXlFfZoOi
QBwMQcS0LFKEoLFbP80P6JDU869DjqS8upKZ75klqne+kFxB6eA13joxpqJgVSYv
lVeSL3i64JZSjqwFXmRFeDX7wUMfFfZoKDYeJoF3RU7Pu73vA0Jpa+d7SkoHrUKG
g9PwApoZosqe/Wo46Wdm8DMr97iEynrOQBVkqcVO8wLXGMOGAmZ8/xEKd4gYAx9v
CH5OJnMy06YH2B2Lil/c+mEmVl01rntn5I4mO3tCzqZ3PzQFDip9q/dzfZTCjYI=
=6RRe
-----END PGP SIGNATURE-----

--nextPart5154744.fNLkcmSmS2--
