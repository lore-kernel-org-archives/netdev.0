From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: init ingress queue
Date: Sun, 05 Dec 2010 22:05:14 +0100
Message-ID: <1291583114.2806.302.camel@edumazet-laptop>
References: <1291465901-3189-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44396 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753896Ab0LEVFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 16:05:23 -0500
Received: by wwa36 with SMTP id 36so12128489wwa.1
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 13:05:22 -0800 (PST)
In-Reply-To: <1291465901-3189-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 d=C3=A9cembre 2010 =C3=A0 20:31 +0800, Changli Gao a =C3=A9=
crit :
> The dev field of ingress queue is forgot to initialized, then NULL
> pointer dereference happens in qdisc_alloc().
>=20
> Move inits of tx queues to netif_alloc_netdev_queues().
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
> v2: factorize the two inits in netdev_init_queues() and move inits of
>     tx queues to netif_alloc_netdev_queues().

This is a net-next-2.6 patch, you forgot to mention it.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



