From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6/sit.c: return unhandled skb to tunnel4_rcv
Date: Wed, 01 Dec 2010 13:19:55 -0800 (PST)
Message-ID: <20101201.131955.68134278.davem@davemloft.net>
References: <20101130053234.GA28609@mcafee.com>
	<1291097564.2725.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: david_mccullough@mcafee.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56269
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753155Ab0LAVT2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 16:19:28 -0500
In-Reply-To: <1291097564.2725.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Nov 2010 07:12:44 +0100

> Le mardi 30 novembre 2010 =E0 15:32 +1000, David McCullough a =E9crit=
 :
>> Hi all,
>>=20
>> I found a problem using an IPv6 over IPv4 tunnel.  When CONFIG_IPV6_=
SIT
>> was enabled, the packets would be rejected as net/ipv6/sit.c was cat=
ching
>> all IPPROTO_IPV6 packets and returning an ICMP port unreachable erro=
r.
>>=20
>> I think this patch fixes the problem cleanly.  I believe the code in
>> net/ipv4/tunnel4.c:tunnel4_rcv takes care of it properly if none of =
the
>> handlers claim the skb.
>>=20
>> Patch is against 2.6.35,  bit still applies to current.
>>=20
>> Cheers,
>> Davidm
>>=20
>> Signed-off-by: David McCullough <david_mccullough@mcafee.com>
 ...
> Good catch !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
