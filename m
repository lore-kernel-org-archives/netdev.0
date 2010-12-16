From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5 v4] net: add old_queue_mapping into skb->cb
Date: Thu, 16 Dec 2010 06:47:18 +0100
Message-ID: <1292478438.2603.57.camel@edumazet-laptop>
References: <1292475410-24665-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43186 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613Ab0LPFrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 00:47:24 -0500
Received: by wyb28 with SMTP id 28so2161790wyb.19
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 21:47:22 -0800 (PST)
In-Reply-To: <1292475410-24665-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 12:56 +0800, Changli Gao a =C3=A9=
crit :
> For the skbs returned from ifb, we should use the queue_mapping
> saved before ifb.
>=20
> We save old queue_mapping in old_queue_mapping just before calling=20
> dev_queue_xmit, and restore the old_queue_mapping to queue_mapping
> just before reinjecting the ingress packets.
>=20
> A new struct dev_skb_cb is added, and valid in qdisc and gso layer.
> The original qdisc_skb_cb and DEV_GSO_CB use dev_skb_cb as the first
> member.
>=20
> netem_skb_cb is changed to contain qdisc_skb_cb.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


