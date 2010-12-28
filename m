From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next-2.6] sch_sfq: allow big packets and be fair
Date: Tue, 28 Dec 2010 13:46:55 -0800 (PST)
Message-ID: <20101228.134655.112609314.davem@davemloft.net>
References: <20101221113920.GB8813@ff.dom.local>
	<20101221121706.GC8813@ff.dom.local>
	<1292936699.2720.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47908
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752433Ab0L1VqZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Dec 2010 16:46:25 -0500
In-Reply-To: <1292936699.2720.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Dec 2010 14:04:59 +0100

> Le mardi 21 d=E9cembre 2010 =E0 12:17 +0000, Jarek Poplawski a =E9cri=
t :
>=20
>> Oops! You're right yet ;-) This skipping shouldn't happen with quant=
um
>> bigger than max packet size, so this patch is OK.
>=20
> Thanks Jarek, here is a v2 with the scale you suggested.
>=20
> [PATCH v2 net-next-2.6] sch_sfq: allow big packets and be fair
>=20
> SFQ is currently 'limited' to small packets, because it uses a 15bit
> allotment number per flow. Introduce a scale by 8, so that we can han=
dle
> full size TSO/GRO packets.
>=20
> Use appropriate handling to make sure allot is positive before a new
> packet is dequeued, so that fairness is respected.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jarek Poplawski <jarkao2@gmail.com>
> Cc: Patrick McHardy <kaber@trash.net>
> ---
> v2: Use a scale of 8 as Jarek suggested, instead of 18bit fields

Eric this doesn't apply cleanly, since the code in sfq_dump_class_stats=
()
is a bit different in net-next-2.6

Please respin this and resubmit.
