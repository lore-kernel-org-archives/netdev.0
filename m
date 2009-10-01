From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Use sk_mark for routing lookup in more places
Date: Thu, 01 Oct 2009 15:18:23 -0700 (PDT)
Message-ID: <20091001.151823.263194343.davem@davemloft.net>
References: <200910011814.47689.atis@mikrotik.com>
	<4AC4D90E.3040008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: atis@mikrotik.com, panther@balabit.hu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52004
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753087AbZJAWSE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 18:18:04 -0400
In-Reply-To: <4AC4D90E.3040008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Oct 2009 18:30:06 +0200

> Atis Elsts a =E9crit :
>> This patch against v2.6.31 adds support for route lookup using sk_ma=
rk in some=20
>> more places. The benefits from this patch are the following.
>> First, SO_MARK option now has effect on UDP sockets too.
>> Second, ip_queue_xmit() and inet_sk_rebuild_header() could fail to d=
o routing=20
>> lookup correctly if TCP sockets with SO_MARK were used.
>>=20
>> Signed-off-by: Atis Elsts <atis@mikrotik.com>
>=20
> Good catch, thanks !
>=20
> I used SO_MARK on connected UDP sockets so did not notice the lack
> of functionality. (ip_route_connect() does use sk->sk_mark)
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.

But Atis, your patch was whitespace corrupted by your email
client so I had to apply your patch by hand.  Please correct
this problem before submitting future patches, thank you.
