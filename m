From: robert@herjulf.net
Subject: Re: [PATCH] pktgen node allocation
Date: Fri, 19 Mar 2010 14:35:22 +0100
Message-ID: <19363.32154.39665.185451@gargle.gargle.HOWL>
References: <19363.14702.909265.380669@gargle.gargle.HOWL>
	<1268990933.3048.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robert Olsson <robert@herjulf.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from klais.its.uu.se ([130.238.7.59]:45865 "EHLO klais.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752256Ab0CSNlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 09:41:09 -0400
In-Reply-To: <1268990933.3048.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet writes:
 > Le vendredi 19 mars 2010 =E0 09:44 +0100, Robert Olsson a =E9crit :
 >=20
 > I cannot understand how this can help.
 >=20
 > __netdev_alloc_skb() is supposed to already take into account NUMA
 > properties :
 >=20
 > int node =3D dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 >=20
 > If this doesnt work, we should correct core stack, not only pktgen :=
)
 >=20
 > Are you allocating memory in the node where pktgen CPU is running or=
 the
 > node close to the NIC ?

 I didn't say it should help the idea was to give some hooks to=20
 experiment and see effects with different node memory allocations.
 There are many degrees of freedom wrt buses(device)/CPU/menory.

 Cheers
				--ro

