From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] unix: Support peeking offset for stream sockets
Date: Tue, 21 Feb 2012 15:05:43 -0500 (EST)
Message-ID: <20120221.150543.782673791038909243.davem@davemloft.net>
References: <4F43D49E.3010401@parallels.com>
	<4F43D516.9060102@parallels.com>
	<1329846679.18384.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754477Ab2BUUFr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 15:05:47 -0500
In-Reply-To: <1329846679.18384.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Feb 2012 18:51:19 +0100

> Le mardi 21 f=E9vrier 2012 =E0 21:32 +0400, Pavel Emelyanov a =E9crit=
 :
>> The same here -- we can protect the sk_peek_off manipulations with
>> the unix_sk->readlock mutex.
>>=20
>> The peeking of data from a stream socket is done in the datagram sty=
le,
>> i.e. even if there's enough room for more data in the user buffer, o=
nly
>> the head skb's data is copied in there. This feature is preserved wh=
en
>> peeking data from a given offset -- the data is read till the neares=
t
>> skb's boundary.
>>=20
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>>=20
>> ---
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
