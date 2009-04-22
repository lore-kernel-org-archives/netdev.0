From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.29.1 1/1] 8139too: fix HW initial flow
Date: Wed, 22 Apr 2009 00:44:32 -0700 (PDT)
Message-ID: <20090422.004432.227765146.davem@davemloft.net>
References: <20090421.015235.23457775.davem@davemloft.net>
	<20090421094825.GA6752@ubuntu>
	<49EDA040.5040600@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jianjun@zeuux.org, jon.lin@vatics.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60683
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752176AbZDVHok convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 03:44:40 -0400
In-Reply-To: <49EDA040.5040600@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 21 Apr 2009 12:30:24 +0200

> Amos Kong a =E9crit :
>> ...
>>  While ifconfig eth0 up kernel calls open() of 8139 driver(8139too.c=
).
>>  In rtl8139_hw_start() of rtl8139_open(), 8139 driver enable RX befo=
re setting up the DMA
>>  buffer address. In this interval where RX was enabled and DMA buffe=
r address is not yet set
>>  up, any incoming broadcast packet would be send to a strange physic=
al address:
>>  0x003e8800 which is the default value of DMA buffer address.
>>  Unfortunately, this address is used by Linux kernel. So kernel pani=
cs.
>>  This patch fix it by setting up DMA buffer address before RX enable=
d and everything is fine
>>  even under broadcast packets attack.
>>=20
>> Signed-off-by: Jonathan Lin <jon.lin@vatics.com>
>> Signed-off-by: Amos Kong <jianjun@zeuux.org>
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Thanks Amos and Jonathan

Applied, thanks everyone.
