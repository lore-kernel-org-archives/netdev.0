From: Marek Lindner <mareklindner@neomailbox.ch>
Subject: Re: [B.A.T.M.A.N.] [PATCH 1/3] batman-adv: use to_delayed_work
Date: Mon, 28 Mar 2016 23:05:52 +0800
Message-ID: <3841474.g7RERK39Gk__5662.2110344053$1459179329$gmane$org@voltaire>
References: <2c0e66fe07809e4069df34cbeba51583ad943c7a.1451317025.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart8108075.Rt1QnjnYaG"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: Geliang Tang <geliangtang@163.com>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <a@unstable.cc>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:41890 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751783AbcC1PfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 11:35:01 -0400
In-Reply-To: <2c0e66fe07809e4069df34cbeba51583ad943c7a.1451317025.git.geliangtang@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart8108075.Rt1QnjnYaG
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Monday, December 28, 2015 23:43:37 Geliang Tang wrote:
> Use to_delayed_work() instead of open-coding it.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
>  net/batman-adv/bridge_loop_avoidance.c | 2 +-
>  net/batman-adv/distributed-arp-table.c | 2 +-
>  net/batman-adv/network-coding.c        | 2 +-
>  net/batman-adv/originator.c            | 2 +-
>  net/batman-adv/send.c                  | 4 ++--
>  net/batman-adv/translation-table.c     | 2 +-
>  6 files changed, 7 insertions(+), 7 deletions(-)

Applied in the batman tree (revision ecc6f9a).

Thanks,
Marek

--nextPart8108075.Rt1QnjnYaG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJW+UhQAAoJEFNVTo/uthzAkqEIAIqggaBrRvMqvhUwF/hEoUsN
tTh+wjHLusDAUGN6l6uiejFChg5uLmjUgzm6uEmCRAEnO+gDuFUGNaBQ5oML2Ioi
kohnli6XL7uUTPOAtEwmQnO9YrEOfYHBKHBJQ1+DB/btXhwXPAw/QWrZLnBU4px1
h2GzIMQzzY9SUOBaWkMZ1sb1bQ07VeMGf5NAFhu0EMMR1Ox7515xhjjzAlzGBuiV
H8Mkrm/uAq6fClJM0feIpAT0OVJ/a7ikjwDiLt6zfUgU1B0Os2VCE3BbL5oJXrlm
D2v0V3sY6lXN9BDxXGZyHkmEmHRkLqp65dFt9wOrEmKZ2xRtc4MinyqE2+PNXsA=
=uFYZ
-----END PGP SIGNATURE-----

--nextPart8108075.Rt1QnjnYaG--
