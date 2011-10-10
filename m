From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: remove unnecessary BUG_ON() in
 tpacket_destruct_skb
Date: Mon, 10 Oct 2011 14:09:51 -0400 (EDT)
Message-ID: <20111010.140951.1248594231055254215.davem@davemloft.net>
References: <20111010185246.15533bv1p3pmnba6@mail.your-server.de>
	<1318266304.3227.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: danborkmann@iogearbox.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031Ab1JJSKQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 14:10:16 -0400
In-Reply-To: <1318266304.3227.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Oct 2011 19:05:04 +0200

> Le lundi 10 octobre 2011 =E0 18:52 +0200, danborkmann@iogearbox.net a
> =E9crit :
>> If skb is NULL, then stack trace is thrown anyway on dereference.
>> Therefore, the stack trace triggered by BUG_ON is duplicate.
>>=20
>> Signed-off-by: Daniel Borkmann <danborkmann@googlemail.com>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, but please make patches like this against the net-next tree
in which the af_packet.c code had changed quite a bit and therefore
I had to munch your patch to get it to apply.
