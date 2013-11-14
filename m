From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: fq: change classification of control packets
Date: Thu, 14 Nov 2013 17:16:59 -0500 (EST)
Message-ID: <20131114.171659.748664517209376981.davem@davemloft.net>
References: <1384447843.28716.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, maze@google.com, willemb@google.com,
	ycheng@google.com, stephen@networkplumber.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53421 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757438Ab3KNWRC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 17:17:02 -0500
In-Reply-To: <1384447843.28716.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Nov 2013 08:50:43 -0800

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> Initial sch_fq implementation copied code from pfifo_fast to classify
> a packet as a high prio packet.
>=20
> This clashes with setups using PRIO with say 7 bands, as one of the
> band could be incorrectly (mis)classified by FQ.
>=20
> Packets would be queued in the 'internal' queue, and no pacing ever
> happen for this special queue.
>=20
> Fixes: afe4fd062416 ("pkt_sched: fq: Fair Queue packet scheduler")
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
