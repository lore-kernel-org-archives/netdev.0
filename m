From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [PATCH 13/17] batman-adv: Consume skb in receive handlers
Date: Tue, 08 Nov 2016 20:05:12 +0100
Message-ID: <3014212.KTtP4ZxDTH@sven-edge>
References: <20161108164526.7518-1-sw@simonwunderlich.de> <2044854.g075mifYzn@bentobox> <1478626981.17367.16.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart4301090.dxVAeb7ts5"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Simon Wunderlich <sw@simonwunderlich.de>, davem@davemloft.net,
        netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:49502 "EHLO v3-1039.vlinux.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753358AbcKHTFW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Nov 2016 14:05:22 -0500
In-Reply-To: <1478626981.17367.16.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart4301090.dxVAeb7ts5
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Dienstag, 8. November 2016 09:43:01 CET Eric Dumazet wrote:
[...]
> Sure, but your patch 13/17 should address this right away.
[...]

Fair enough. I've asked Simon to resubmit the patches with the
"consume_skb -> conditional kfree_skb/consume_skb" patch squashed
into patch 13.

Kind regards,
	Sven

--nextPart4301090.dxVAeb7ts5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJYIiHoAAoJEF2HCgfBJntGMVkP/2iOM+5iWWxrl68tAhsqOVXn
T9Khl+S8DOYkw2VZTphJ1VtAWRBUgAn80zH0V4FaD3qd6ImG8AD6hWFdt6i/94hK
1TiSqUgn5qkzwGRGxEcpXmgiYcavY1DbNFXTVnqidxA5602wk6/DnyE4nDCq0y/5
aACJdj9iadort5+rXUFX70KRs/tcF78piKaN4LNwtq5pxLV+MY1OjHqPpc6oI7XX
6f69dG0LDTcNR7RhwjVDRcV0aTpXnVhEjUTckDVWkWM5cEZAbBHlQ1WKDZm0kbT2
YicNtLvb+gEDK1CZx9tkYanQwNXc47HnRW0TcTASAo7GchPy+2xosO96yWtES/UP
owPEyP8PtYche41Xxr4YLNecqPeRcTI/GPOydNSLraVXEkPy8Kv2ZxbbyKQKPn+a
F0GdlPnCDbPzashGBf3cjCdCySFveypumR1kwvtO4gVK17dG7kKfo8dYYj1aDfl/
IugWyIysjzES+Q02LEa4RFLQFkM54rOGfcNOB99OuKlkxZUAV22XUa3JaAO2kN83
8bfvbzoFzJj4VEMyWZINGgiRVe9CBm1xz87BIUQPObldQcBMW1mChq5PkxhXHpcs
i6m03UHxbvdgY8FEsqw1MZ95e6h280YtFKoNdE3WFUIckZFHSvyuhTBHH9ema2e6
/1Qo/gSONzEvh45UKvLF
=7vpt
-----END PGP SIGNATURE-----

--nextPart4301090.dxVAeb7ts5--
