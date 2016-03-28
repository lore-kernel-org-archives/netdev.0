From: Marek Lindner <mareklindner@neomailbox.ch>
Subject: Re: [B.A.T.M.A.N.] [PATCH 07/14] batman-adv: use list_for_each_entry_safe
Date: Mon, 28 Mar 2016 23:02:57 +0800
Message-ID: <1757463.snOK1GtmKT__20551.5115442269$1459179457$gmane$org@voltaire>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com> <b01d3ee936833e94fffa53f7a82fc46e20d877c1.1450451516.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart3551843.hWh1a8QZUi"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: Geliang Tang <geliangtang@163.com>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <a@unstable.cc>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:3929 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752775AbcC1PhT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 11:37:19 -0400
In-Reply-To: <b01d3ee936833e94fffa53f7a82fc46e20d877c1.1450451516.git.geliangtang@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3551843.hWh1a8QZUi
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Friday, December 18, 2015 23:33:31 Geliang Tang wrote:
> Use list_for_each_entry_safe() instead of list_for_each_safe() to
> simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
>  net/batman-adv/icmp_socket.c | 22 +++++++++-------------
>  1 file changed, 9 insertions(+), 13 deletions(-)

Applied in the batman tree (revision 1557404).

Thanks,
Marek

--nextPart3551843.hWh1a8QZUi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJW+UehAAoJEFNVTo/uthzA8eoH/RA+nmwipTRTPgGKo+nNKXK8
9Dcz9C2znHPsFV7yISAwXvMesH0Tr78jGfFezO/tqKeVEQ9MykIdKpvR8Y4c7vvI
xjpCEaHX2lgfMNZXjbbjKY3sdJUN+HUhaDvRFbn6h7OIbF/KfllwHmpb3tYnH+hq
JyxWOT4vsL19tRF1KY5rNVN+8TxfDTrBwF8Fi5cvMFZd1XgF7Ip7EqhUPNlMyEOk
qKdlAR/t+YqIeB0+cxwwlgsWUYOuat6APbNaS2kl3p2f+3sDOowl8ykknKVBIBMg
BhONPHZQlz+ef0LiLsuqtMj6Qd17nIUg5lNsPq48RbjJzdOirzHBKHTAlNSNcn0=
=cST+
-----END PGP SIGNATURE-----

--nextPart3551843.hWh1a8QZUi--
