From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "net: fec: fix the warning found by dma
 debug"
Date: Fri, 13 Mar 2015 13:10:50 -0400 (EDT)
Message-ID: <20150313.131050.1339443777953236469.davem@davemloft.net>
References: <1426266474-6018-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: b38611@freescale.com, netdev@vger.kernel.org, rockford@yandex.ru,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbbCMRKw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 13:10:52 -0400
In-Reply-To: <1426266474-6018-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fabio Estevam <festevam@gmail.com>
Date: Fri, 13 Mar 2015 14:07:54 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
>=20
> This reverts commit 2b995f63987013bacde99168218f9c7b252bdcf1.
>=20
> =F0=C1=CE=CF=D7 =E1=CE=C4=D2=C5=CA reported the following regression:
>=20
> "Commit 2b995f63987013bacde99168218f9c7b252bdcf1 in 4.0.0-rc3 introdu=
ces a
> nasty bug in transmit, corrupting packets.
>=20
> To reproduce:
>=20
> $ dd if=3D/dev/zero of=3Dzeros bs=3D1M count=3D20
> $ md5sum -b zeros
> 8f4e33f3dc3e414ff94e5fb6905cba8c *zeros
>=20
> This checksum is correct.
>=20
> Copy file "zeros" to another host with NFS, and it gets corrupted, ch=
ecksum is
> changed.
> File should be big, small amounts of transmit isn't affected.
>=20
> I use an i.MX6 Quad board.
>=20
> If this commit is reverted, all works fine."
>=20
> Reported-by: =F0=C1=CE=CF=D7 =E1=CE=C4=D2=C5=CA <rockford@yandex.ru>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
