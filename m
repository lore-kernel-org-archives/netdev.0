From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] xfrm: fix xfrm by MARK logic
Date: Sun, 04 Jul 2010 11:46:27 -0700 (PDT)
Message-ID: <20100704.114627.48496869.davem@davemloft.net>
References: <20100702174755.GA12509@myhost>
	<1278139083.2474.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: p.kosyh@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36872
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757845Ab0GDSqN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jul 2010 14:46:13 -0400
In-Reply-To: <1278139083.2474.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 03 Jul 2010 08:38:03 +0200

> Le vendredi 02 juillet 2010 =E0 21:47 +0400, Peter Kosyh a =E9crit :
>> From: Peter Kosyh <p.kosyh@gmail.com>
>>=20
>> While using xfrm by MARK feature in
>> 2.6.34 - 2.6.35 kernels, the mark=20
>> is always cleared in flowi structure via memset in=20
>> _decode_session4 (net/ipv4/xfrm4_policy.c), so
>> the policy lookup fails.
>> IPv6 code is affected by this bug too.
>>=20
>> Signed-off-by: Peter Kosyh <p.kosyh@gmail.com>
>> ---
>>=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
