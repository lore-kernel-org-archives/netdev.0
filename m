From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 26 Apr 2011 23:08:12 +0200
Message-ID: <1303852092.2699.11.camel@edumazet-laptop>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	 <1303730701.2747.110.camel@edumazet-laptop>
	 <BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
	 <1303850622.2699.6.camel@edumazet-laptop>
	 <BANLkTint2-Fg35T9SqWPm3nOaoc1d=ZEnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>, netdev@vger.kernel.org
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44632 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758184Ab1DZVIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 17:08:17 -0400
Received: by wwa36 with SMTP id 36so1180753wwa.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 14:08:16 -0700 (PDT)
In-Reply-To: <BANLkTint2-Fg35T9SqWPm3nOaoc1d=ZEnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 avril 2011 =C3=A0 23:04 +0200, Dominik Kaspar a =C3=A9crit =
:

> In these experiments, a queue size of 1000 packets was specified. I a=
m
> aware that this is typically referred to as "buffer bloat" and causes
> the RTT and the cwnd to grow excessively. The smaller I configure the
> queues, the more time it takes for TCP to "level up" to the aggregate
> throughput. By keeping the queues so large, I hope to more quickly
> identify the reason why TCP is actually able to adjust to the immense
> multipath reordering. What parameters could be highly relevant, other
> than the queue size?
>=20

losses of course ;)

Real internet is full of packet losses, and probability of these losses
depends on queue sizes (RED like AQM)


> Thanks for the tip about printing tc/netem statistics after each run,
> I will use "tc -s -d qdisc" next time.
>=20


