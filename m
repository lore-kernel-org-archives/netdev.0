From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ieee802154: merge cleanup
Date: Tue, 01 Dec 2009 07:05:22 +0100
Message-ID: <4B14B222.8090203@gmail.com>
References: <20091130.010520.56312368.davem@davemloft.net>	<4B149498.4030307@gmail.com> <20091130.215501.267396660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54458 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163AbZLAGFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 01:05:20 -0500
In-Reply-To: <20091130.215501.267396660.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 01 Dec 2009 04:59:20 +0100
>=20
>> A small cleanup after last net-2.6 merge into net-next-2.6
>>
>> As we are going to free skb, no need to set skb->skb_iif or skb->dev
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> -ECORRUPTEDPATCH
>=20
> Are you really sure you want to keep using Thunderbird for
> your email? :-)

Sorry, my bad, sending patches at 4h30 am is error prone,
I did a stupid copy/paste from a wrong window.

[PATCH net-next-2.6] ieee802154: merge cleanup

A small cleanup after last net-2.6 merge into net-next-2.6

As we are going to free skb, no need to set skb->skb_iif or skb->dev

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/ieee802154/fakehard.c |    3 ---
 1 files changed, 3 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehar=
d.c
index 5f67540..d9d0e13 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -282,9 +282,6 @@ static int ieee802154_fake_close(struct net_device =
*dev)
 static netdev_tx_t ieee802154_fake_xmit(struct sk_buff *skb,
 					      struct net_device *dev)
 {
-	skb->skb_iif =3D dev->ifindex;
-	skb->dev =3D dev;
-
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes +=3D skb->len;
=20
