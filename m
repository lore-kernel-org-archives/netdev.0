From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Tue, 10 Apr 2012 15:29:23 +1000
Message-ID: <20120410152923.15aee4df478d819f167cd4af@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__10_Apr_2012_15_29_23_+1000_fqp4ut43H.D7NEk7"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mike Sinkovsky <msink@permonline.ru>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:34582 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab2DJF3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 01:29:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__10_Apr_2012_15_29_23_+1000_fqp4ut43H.D7NEk7
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (s390 allmodconfig)
failed like this:

drivers/net/ethernet/wiznet/w5100.c: In function 'w5100_read_direct':
drivers/net/ethernet/wiznet/w5100.c:121:2: error: implicit declaration of f=
unction 'ioread8' [-Werror=3Dimplicit-function-declaration]
drivers/net/ethernet/wiznet/w5100.c: In function 'w5100_write_direct':
drivers/net/ethernet/wiznet/w5100.c:127:2: error: implicit declaration of f=
unction 'iowrite8' [-Werror=3Dimplicit-function-declaration]
drivers/net/ethernet/wiznet/w5100.c: In function 'w5100_read_indirect':
drivers/net/ethernet/wiznet/w5100.c:188:2: error: implicit declaration of f=
unction 'mmiowb' [-Werror=3Dimplicit-function-declaration]
drivers/net/ethernet/wiznet/w5100.c: In function 'w5100_hw_probe':
drivers/net/ethernet/wiznet/w5100.c:680:6: error: 'IRQ_TYPE_LEVEL_LOW' unde=
clared (first use in this function)

Caused by commit 8b1467a31343 ("Ethernet driver for the WIZnet W5100 chip").
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__10_Apr_2012_15_29_23_+1000_fqp4ut43H.D7NEk7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPg8UzAAoJEECxmPOUX5FEj2QQAKIPTrkfZAgchm+3LDtneWk/
aAOxt8O6f9qsUb2QFk9YtMVnSdYlPADAQXy39DMA9jo+P+gGVCxlevd+lDd9by0y
eRWh/o4G06li1RJW6atldCG4fgE5ehwcMazhAzl1sSxfPDQBCNQnDPa7vFIol99q
Hy1dJPW8h5a2pjq9vBuzTvpggyJizU6ll0lpY97snR9alATo9jG+dd63WPyL/kBz
xNOAGiBLfYDJAQ82njXMQqNHAJL8URPJF7XgFbHAbf9YxXHmvO+nJK5gofQsORGl
P9yQ4CBAq88CrguGmKNfRD+kNO0mzKByXtjjVQIYrpET/IHHdUDQpcBlhVzUfrld
bFQIzAVjcOtPX4uQ11Lrf41gV1iGo7vrKUKYRrxzXw2B0Woq1p1TK0n+sD3AzWRj
8InLz0Tn0vnq92pyrNJAQjMZsDosOZg1jEbwIN3TAo/B86prRhMNUVwq98zFUmCV
1fZPT/gmdqnEla4pa8pjdhu5lzgmf1PCoOVz9/1oibdAq1DVmcwEhWKjwf6gxxhi
TXEE//1n5s+rTLkQEHul4Pxsm6eF74A10jST7y9Clh3MOcXB13ybIUqUZGbTh3VJ
0kxLLmFkpPgb/SGAdJ3vEf8/IXHxqD0i/UrJTJqpBb9q8KNPM2ztXW9QKIxTBr+E
W/3JWZ0kVU/wIJYwKT5M
=vuHG
-----END PGP SIGNATURE-----

--Signature=_Tue__10_Apr_2012_15_29_23_+1000_fqp4ut43H.D7NEk7--
