From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: accurate bytes/packets stats/rates
Date: Fri, 14 Jan 2011 19:08:22 +0100
Message-ID: <1295028502.3937.116.camel@edumazet-laptop>
References: <1295021808.3937.110.camel@edumazet-laptop>
	 <20110114095201.4fc58a45@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33038 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414Ab1ANSI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 13:08:27 -0500
Received: by eye27 with SMTP id 27so1577915eye.19
        for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 10:08:25 -0800 (PST)
In-Reply-To: <20110114095201.4fc58a45@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 janvier 2011 =C3=A0 09:52 -0800, Stephen Hemminger a =C3=
=A9crit :
> By using __qdisc_queue_drop_head in sch_fifo.c the stats_update param=
eter won't be
> needed.


Hmm, this is a constant parameter in inline function so removed by
compiler.

And you add a bug in pfifo_tail_enqueue(), it now lacks the
sch->qstats.drops++;

>=20
> From Eric Dumazet <eric.dumazet@gmail.com>
>=20

Note : This line should be the first one in mail ;)



