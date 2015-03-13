From: David Miller <davem@davemloft.net>
Subject: Re: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is
 broken. In 4.0.0-rc3
Date: Fri, 13 Mar 2015 12:41:38 -0400 (EDT)
Message-ID: <20150313.124138.958968404157280157.davem@davemloft.net>
References: <390621425930628@web28o.yandex.ru>
	<1426254527.4173.98.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rockford@yandex.ru, b38611@freescale.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbbCMQlk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 12:41:40 -0400
In-Reply-To: <1426254527.4173.98.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 13 Mar 2015 13:48:47 +0000

> On Mon, 2015-03-09 at 22:50 +0300, =F0=C1=CE=CF=D7 =E1=CE=C4=D2=C5=CA=
 wrote:
>> Hello!
>>=20
>> Commit 2b995f63987013bacde99168218f9c7b252bdcf1 in 4.0.0-rc3 introdu=
ces a nasty bug in transmit, corrupting packets.
>>=20
>> To reproduce:
>>=20
>> $ dd if=3D/dev/zero of=3Dzeros bs=3D1M count=3D20
>> $ md5sum -b zeros
>> 8f4e33f3dc3e414ff94e5fb6905cba8c *zeros
>>=20
>> This checksum is correct.
>>=20
>> Copy file "zeros" to another host with NFS, and it gets corrupted, c=
hecksum is changed.
>> File should be big, small amounts of transmit isn't affected.
>>=20
>> I use an i.MX6 Quad board.
>>=20
>> If this commit is reverted, all works fine.
>=20
> And the bug described in the commit message doesn't seem to exist in =
the
> previous version.  The change just doesn't make sense to me.
>=20
> I seem to remember DMA debug checks sometimes causing false positives
> for network I/O, too.

I'd be happy to apply a revert.
