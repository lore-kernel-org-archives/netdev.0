From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 v2] net: fix nulls list corruptions in
 sk_prot_alloc
Date: Thu, 16 Dec 2010 14:16:00 -0800 (PST)
Message-ID: <20101216.141600.116387366.davem@davemloft.net>
References: <1292347187-24154-1-git-send-email-opurdila@ixiacom.com>
	<1292361811.2478.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org, lcrestez@ixiacom.com,
	stable@kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53040
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752078Ab0LPWPb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 17:15:31 -0500
In-Reply-To: <1292361811.2478.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Dec 2010 22:23:31 +0100

> Le mardi 14 d=E9cembre 2010 =E0 19:19 +0200, Octavian Purdila a =E9cr=
it :
>> Special care is taken inside sk_port_alloc to avoid overwriting
>> skc_node/skc_nulls_node. We should also avoid overwriting
>> skc_bind_node/skc_portaddr_node.
>>=20
>> The patch fixes the following crash:
>>=20
>>  BUG: unable to handle kernel paging request at fffffffffffffff0
>>  IP: [<ffffffff812ec6dd>] udp4_lib_lookup2+0xad/0x370
>>  [<ffffffff812ecc22>] __udp4_lib_lookup+0x282/0x360
>>  [<ffffffff812ed63e>] __udp4_lib_rcv+0x31e/0x700
>>  [<ffffffff812bba45>] ? ip_local_deliver_finish+0x65/0x190
>>  [<ffffffff812bbbf8>] ? ip_local_deliver+0x88/0xa0
>>  [<ffffffff812eda35>] udp_rcv+0x15/0x20
>>  [<ffffffff812bba45>] ip_local_deliver_finish+0x65/0x190
>>  [<ffffffff812bbbf8>] ip_local_deliver+0x88/0xa0
>>  [<ffffffff812bb2cd>] ip_rcv_finish+0x32d/0x6f0
>>  [<ffffffff8128c14c>] ? netif_receive_skb+0x99c/0x11c0
>>  [<ffffffff812bb94b>] ip_rcv+0x2bb/0x350
>>  [<ffffffff8128c14c>] netif_receive_skb+0x99c/0x11c0
>>=20
>> Signed-off-by: Leonard Crestez <lcrestez@ixiacom.com>
>> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: stable@kernel.org
>> ---
>=20
> Thanks Octavian !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
