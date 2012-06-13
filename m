From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: remove packet cloning in recv_probe()
Date: Tue, 12 Jun 2012 18:52:10 -0700 (PDT)
Message-ID: <20120612.185210.950874013557330917.davem@davemloft.net>
References: <1339478587.22704.16.camel@edumazet-glaptop>
	<24088.1339548479@death.nxdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, andy@greyhouse.net,
	jbohac@suse.cz, nicolas.2p.debian@free.fr, maze@google.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab2FMBwL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 21:52:11 -0400
In-Reply-To: <24088.1339548479@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 12 Jun 2012 17:47:59 -0700

> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>>From: Eric Dumazet <edumazet@google.com>
>>
>>Cloning all packets in input path have a significant cost.
>>
>>Use skb_header_pointer()/skb_copy_bits() instead of pskb_may_pull() s=
o
>>that recv_probe handlers (bond_3ad_lacpdu_recv / bond_arp_rcv /
>>rlb_arp_recv ) dont touch input skb.
>>
>>bond_handle_frame() can avoid the skb_clone()/dev_kfree_skb()
>>
>>Signed-off-by: Eric Dumazet <edumazet@google.com>
>>Cc: Jay Vosburgh <fubar@us.ibm.com>
>>Cc: Andy Gospodarek <andy@greyhouse.net>
>>Cc: Jiri Bohac <jbohac@suse.cz>
>>Cc: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
>>Cc: Maciej =AFenczykowski <maze@google.com>
>=20
> 	This looks really good to me.
>=20
> 	-J
>=20
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied.
