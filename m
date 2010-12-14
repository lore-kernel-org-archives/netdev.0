From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6 v2] net: fix nulls list corruptions in
 sk_prot_alloc
Date: Tue, 14 Dec 2010 22:23:31 +0100
Message-ID: <1292361811.2478.3.camel@edumazet-laptop>
References: <1292347187-24154-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Leonard Crestez <lcrestez@ixiacom.com>,
	stable@kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59535 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760113Ab0LNVXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 16:23:36 -0500
Received: by wwa36 with SMTP id 36so944487wwa.1
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 13:23:34 -0800 (PST)
In-Reply-To: <1292347187-24154-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 d=C3=A9cembre 2010 =C3=A0 19:19 +0200, Octavian Purdila a =C3=
=A9crit :
> Special care is taken inside sk_port_alloc to avoid overwriting
> skc_node/skc_nulls_node. We should also avoid overwriting
> skc_bind_node/skc_portaddr_node.
>=20
> The patch fixes the following crash:
>=20
>  BUG: unable to handle kernel paging request at fffffffffffffff0
>  IP: [<ffffffff812ec6dd>] udp4_lib_lookup2+0xad/0x370
>  [<ffffffff812ecc22>] __udp4_lib_lookup+0x282/0x360
>  [<ffffffff812ed63e>] __udp4_lib_rcv+0x31e/0x700
>  [<ffffffff812bba45>] ? ip_local_deliver_finish+0x65/0x190
>  [<ffffffff812bbbf8>] ? ip_local_deliver+0x88/0xa0
>  [<ffffffff812eda35>] udp_rcv+0x15/0x20
>  [<ffffffff812bba45>] ip_local_deliver_finish+0x65/0x190
>  [<ffffffff812bbbf8>] ip_local_deliver+0x88/0xa0
>  [<ffffffff812bb2cd>] ip_rcv_finish+0x32d/0x6f0
>  [<ffffffff8128c14c>] ? netif_receive_skb+0x99c/0x11c0
>  [<ffffffff812bb94b>] ip_rcv+0x2bb/0x350
>  [<ffffffff8128c14c>] netif_receive_skb+0x99c/0x11c0
>=20
> Signed-off-by: Leonard Crestez <lcrestez@ixiacom.com>
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: stable@kernel.org
> ---

Thanks Octavian !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



