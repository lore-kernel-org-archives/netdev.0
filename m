From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [PATCH 13/17] batman-adv: Consume skb in receive handlers
Date: Tue, 08 Nov 2016 18:28:02 +0100
Message-ID: <2044854.g075mifYzn@bentobox>
References: <20161108164526.7518-1-sw@simonwunderlich.de> <20161108164526.7518-14-sw@simonwunderlich.de> <1478624389.17367.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart19485984.88u8rGP59H"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Simon Wunderlich <sw@simonwunderlich.de>, davem@davemloft.net,
        netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:49476 "EHLO v3-1039.vlinux.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932996AbcKHR2H (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Nov 2016 12:28:07 -0500
In-Reply-To: <1478624389.17367.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart19485984.88u8rGP59H
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Dienstag, 8. November 2016 08:59:49 CET Eric Dumazet wrote:
[...]
> > +free_skb:
> >  	consume_skb(skb);
> > -	return NET_RX_SUCCESS;
> > +
> > +	return ret;
> >  }
> 
> 
> Okay, but we do have kfree_skb() and consume_skb() and they should be
> used appropriately.

Yes, this patch is one part of reaching this goal. Some other parts are also
in this patchset. But other changes like the one you've mention here (change
some consume_skb partially back to kfree_skb) have still to be done. But
first we have to clean up the main portion of the mess :)

Kind regards,
	Sven
--nextPart19485984.88u8rGP59H
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJYIgsiAAoJEF2HCgfBJntGHbAP/iC8CjIcYNWBK6PORprNkgmd
DdhbpxGA/MbmA62tm1QHUnaXx3rkXD6gJIJF4WUWodg11KlO3lKXWRSBcUmXp1jE
UJVZCXI5W2ihk6O+1RSQ7qt2q6Hi2OndVy73+mHm9epPdqVkNvsQHM/MNi7xofeO
se1Nkv3EjLxg67T8b+s4DlOQDZEa5kmgRL4fXTe1xscMg+tEpAF4zrlN4uCcVOVc
/nGNQfRqNfcTATRkXYQt+7d2KCmPwlNqNVf88El/mS3f0RHT8Z8pAIkcxjGfW6Tc
ZZgY8nYBGfRUKe2+/qECaPU+3t7D8dse4tdTaRtMy2szMdonFGpooEEhrp7/Rdz4
OYaw6SD0H8XjNA09dxclD8UB6YSUYHuo2JHXdpZoyjmD3jU8cceytKpxo1OzhTz0
99VsuUzHwYQvKrLdfA42Qeoo8tI/NzO7lc7Xn30hXp9xPBn1/39rBqBet0Bfxxfq
uZ8TFOatO3tiLePfbTZK3Go0R+6UUsz/fpc6HH9hCXcaxxXLXiV5b4UjmARP/Yzq
2LZvoCIUWX2Ub0BRgvKcIunZq24XVEwabF7dRp8dfOguRRANAvoxVbvCcSYkgnNx
XHUC5iSQKw0kr0B3b2BF94mqw4B1daXqKEyWhxoUI8/1hXwUNVO8ImD5G4mWZHXA
LIZWtFlXhoevJxPZQJvg
=3YVA
-----END PGP SIGNATURE-----

--nextPart19485984.88u8rGP59H--
