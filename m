From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] datagram: Add offset argument to
 __skb_recv_datagram
Date: Tue, 21 Feb 2012 15:04:21 -0500 (EST)
Message-ID: <20120221.150421.2100924987981258228.davem@davemloft.net>
References: <4F43D49E.3010401@parallels.com>
	<4F43D4D2.5080903@parallels.com>
	<1329846032.18384.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456Ab2BUUE0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 15:04:26 -0500
In-Reply-To: <1329846032.18384.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Feb 2012 18:40:32 +0100

> Le mardi 21 f=E9vrier 2012 =E0 21:30 +0400, Pavel Emelyanov a =E9crit=
 :
>> This one is only considered for MSG_PEEK flag and the value pointed =
by
>> it specifies where to start peeking bytes from. If the offset happen=
s to
>> point into the middle of the returned skb, the offset within this sk=
b is
>> put back to this very argument.
>>=20
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>>=20
>> ---
>>  include/linux/skbuff.h |    2 +-
>>  net/core/datagram.c    |   21 +++++++++++++--------
>>  net/ipv4/udp.c         |    4 ++--
>>  net/ipv6/udp.c         |    4 ++--
>>  4 files changed, 18 insertions(+), 13 deletions(-)
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
