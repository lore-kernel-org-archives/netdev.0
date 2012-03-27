From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ethernet: ks8851_mll fix rx frame buffer overflow
Date: Tue, 27 Mar 2012 17:31:09 -0400 (EDT)
Message-ID: <20120327.173109.1316744556125544111.davem@davemloft.net>
References: <20120327130144.GA555@recalcati>
	<1332859171.10620.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ciminaghi@gnudd.com, adobriyan@gmail.com, thomas@m3y3r.de,
	mcuos.com@gmail.com, lucas.demarchi@profusion.mobi,
	netdev@vger.kernel.org, raffaele.recalcati@bticino.it
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45951 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754606Ab2C0VeW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 17:34:22 -0400
In-Reply-To: <1332859171.10620.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Mar 2012 07:39:31 -0700

> Le mardi 27 mars 2012 =E0 15:01 +0200, Davide Ciminaghi a =E9crit :
>> @@ -40,7 +40,7 @@
>>  #define	DRV_NAME	"ks8851_mll"
>> =20
>>  static u8 KS_DEFAULT_MAC_ADDRESS[] =3D { 0x00, 0x10, 0xA1, 0x86, 0x=
95, 0x11 };
>> -#define MAX_RECV_FRAMES			32
>> +#define MAX_RECV_FRAMES			256
>>  #define MAX_BUF_SIZE			2048
>>  #define TX_BUF_SIZE			2000
>>  #define RX_BUF_SIZE			2000
>=20
> How can this fix the problem for good ?

Indeed.
