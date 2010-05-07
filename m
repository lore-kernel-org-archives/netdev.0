From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: udp: make short packet logging consistent with
 ipv4
Date: Thu, 06 May 2010 21:50:34 -0700 (PDT)
Message-ID: <20100506.215034.43036998.davem@davemloft.net>
References: <1273153475-32363-1-git-send-email-bjorn@mork.no>
	<1273153475-32363-2-git-send-email-bjorn@mork.no>
	<1273157366.2853.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48704
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750703Ab0EGEu1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 May 2010 00:50:27 -0400
In-Reply-To: <1273157366.2853.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 May 2010 16:49:26 +0200

> Le jeudi 06 mai 2010 =E0 15:44 +0200, Bj=F8rn Mork a =E9crit :
>> Adding addresses and ports to the short packet log message,
>> like ipv4/udp.c does it, makes these messages a lot more useful:
>>=20
>> [  822.182450] UDPv6: short packet: From [2001:db8:ffb4:3::1]:47839 =
23715/178 to [2001:db8:ffb4:3:5054:ff:feff:200]:1234
>>=20
>> This requires us to drop logging in case pskb_may_pull() fails,
>> which also is consistent with ipv4/udp.c
>>=20
>> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
>> ---
>>  net/ipv6/udp.c |   11 ++++++++---
>>  1 files changed, 8 insertions(+), 3 deletions(-)
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6, thanks.
