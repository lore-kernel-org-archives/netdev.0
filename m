From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/2] netdev: buffer infrastructure to log network
 driver's information
Date: Mon, 05 Apr 2010 10:42:26 +0200
Message-ID: <1270456946.1971.27.camel@edumazet-laptop>
References: <4BB98828.5030302@jp.fujitsu.com>
	 <4BB988C9.9070709@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com,
	kaneshige.kenji@jp.fujitsu.com, davem@davemloft.net,
	nhorman@tuxdriver.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:42410 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954Ab0DEIme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 04:42:34 -0400
Received: by bwz1 with SMTP id 1so2657954bwz.21
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 01:42:32 -0700 (PDT)
In-Reply-To: <4BB988C9.9070709@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 avril 2010 =C3=A0 15:52 +0900, Koki Sanagi a =C3=A9crit :
> This patch implements buffer infrastructure under driver/net.
> This buffer records information from network driver.
>=20
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
>   drivers/net/Kconfig     |    8 +
>   drivers/net/Makefile    |    1 +
>   drivers/net/ndrvbuf.c   |  535 ++++++++++++++++++++++++++++++++++++=
+++++++++++
>   include/linux/ndrvbuf.h |   57 +++++
>   4 files changed, 601 insertions(+), 0 deletions(-)
>=20

Wow, 600 lines... thats what I call bloat...

Why no use a very simple interface (printk like) ?

xxx_printf(dev->trace, "xmit qidx=3D%u ntu=3D%d->%d\n",
	   tx_ring->queue_index, first, tx_ring->next_to_use);

Anyway, this has nothing to do with network drivers and should be
discussed on lkml.



