From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen node allocation
Date: Fri, 19 Mar 2010 14:47:45 +0100
Message-ID: <1269006465.3048.39.camel@edumazet-laptop>
References: <19363.14702.909265.380669@gargle.gargle.HOWL>
	 <1268990933.3048.15.camel@edumazet-laptop>
	 <19363.32154.39665.185451@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: robert@herjulf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:37232 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256Ab0CSNru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 09:47:50 -0400
Received: by bwz1 with SMTP id 1so42355bwz.21
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 06:47:49 -0700 (PDT)
In-Reply-To: <19363.32154.39665.185451@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 mars 2010 =C3=A0 14:35 +0100, robert@herjulf.net a =C3=A9=
crit :
> Eric Dumazet writes:
>  > Le vendredi 19 mars 2010 =C3=A0 09:44 +0100, Robert Olsson a =C3=A9=
crit :
>  >=20
>  > I cannot understand how this can help.
>  >=20
>  > __netdev_alloc_skb() is supposed to already take into account NUMA
>  > properties :
>  >=20
>  > int node =3D dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
>  >=20
>  > If this doesnt work, we should correct core stack, not only pktgen=
 :)
>  >=20
>  > Are you allocating memory in the node where pktgen CPU is running =
or the
>  > node close to the NIC ?
>=20
>  I didn't say it should help the idea was to give some hooks to=20
>  experiment and see effects with different node memory allocations.
>  There are many degrees of freedom wrt buses(device)/CPU/menory.
>=20

Well, you said "Tested this with 10 Intel 82599 ports w. TYAN S7025
E5520 CPU's. Was able to TX/DMA ~80 Gbit/s to Ethernet wires."

I am interested to know what particular setup you did to maximize
throughput then, or are you saing you managed to reduce it ? :)


