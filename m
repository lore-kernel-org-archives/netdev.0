From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] unix: Support peeking offset for datagram and
 seqpacket sockets
Date: Tue, 21 Feb 2012 15:05:38 -0500 (EST)
Message-ID: <20120221.150538.1746704835094201030.davem@davemloft.net>
References: <4F43D49E.3010401@parallels.com>
	<4F43D507.9010905@parallels.com>
	<1329846596.18384.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754477Ab2BUUFn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 15:05:43 -0500
In-Reply-To: <1329846596.18384.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Feb 2012 18:49:56 +0100

> Le mardi 21 f=E9vrier 2012 =E0 21:31 +0400, Pavel Emelyanov a =E9crit=
 :
>> The sk_peek_off manipulations are protected with the unix_sk->readlo=
ck mutex.
>> This mutex is enough since all we need is to syncronize setting the =
offset
>> vs reading the queue head. The latter is fully covered with the ment=
ioned lock.
>>=20
>> The recently added __skb_recv_datagram's offset is used to pick the =
skb to
>> read the data from.
>>=20
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>>=20
>> ---
>>  net/unix/af_unix.c |   30 +++++++++++++++++++++++++-----
>>  1 files changed, 25 insertions(+), 5 deletions(-)
>=20
> Very nice !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
