From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: percpu net_device refcount
Date: Mon, 11 Oct 2010 21:51:25 +0200
Message-ID: <1286826685.3218.16.camel@edumazet-laptop>
References: <20101011.121344.260085789.davem@davemloft.net>
	 <1286825929.3218.7.camel@edumazet-laptop>
	 <20101011.124137.102555159.davem@davemloft.net>
	 <20101011.124938.179933637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53859 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122Ab0JKTvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 15:51:35 -0400
Received: by wye20 with SMTP id 20so753782wye.19
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 12:51:34 -0700 (PDT)
In-Reply-To: <20101011.124938.179933637.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 octobre 2010 =C3=A0 12:49 -0700, David Miller a =C3=A9crit =
:

> Actually I have to revert, this breaks the infiniband drivers
> which access netdev->refcnt directly.
>=20
> drivers/infiniband/hw/nes/nes_verbs.c: In function 'nes_alloc_pd':
> drivers/infiniband/hw/nes/nes_verbs.c:786:2: error: 'struct net_devic=
e' has no member named 'refcnt'
> drivers/infiniband/hw/nes/nes_verbs.c: In function 'nes_create_qp':
> drivers/infiniband/hw/nes/nes_verbs.c:1418:2: error: 'struct net_devi=
ce' has no member named 'refcnt'
> drivers/infiniband/hw/nes/nes_cm.c: In function 'nes_disconnect':
> drivers/infiniband/hw/nes/nes_cm.c:2703:2: error: 'struct net_device'=
 has no member named 'refcnt'
> drivers/infiniband/hw/nes/nes_cm.c: In function 'nes_accept':
> drivers/infiniband/hw/nes/nes_cm.c:2793:2: error: 'struct net_device'=
 has no member named 'refcnt'

Ah ok, I'll make a build test before submitting v3, sorry for the
inconvenience.

Thanks


