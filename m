From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 26 Apr 2011 23:17:59 +0200
Message-ID: <1303852679.2699.13.camel@edumazet-laptop>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	 <1303730701.2747.110.camel@edumazet-laptop>
	 <BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
	 <1303850622.2699.6.camel@edumazet-laptop>
	 <BANLkTint2-Fg35T9SqWPm3nOaoc1d=ZEnQ@mail.gmail.com>
	 <1303852092.2699.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>, netdev@vger.kernel.org
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54419 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758882Ab1DZVSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 17:18:05 -0400
Received: by wwa36 with SMTP id 36so1188443wwa.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 14:18:04 -0700 (PDT)
In-Reply-To: <1303852092.2699.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 avril 2011 =C3=A0 23:08 +0200, Eric Dumazet a =C3=A9crit :
> Le mardi 26 avril 2011 =C3=A0 23:04 +0200, Dominik Kaspar a =C3=A9cri=
t :
>=20
> > In these experiments, a queue size of 1000 packets was specified. I=
 am
> > aware that this is typically referred to as "buffer bloat" and caus=
es
> > the RTT and the cwnd to grow excessively. The smaller I configure t=
he
> > queues, the more time it takes for TCP to "level up" to the aggrega=
te
> > throughput. By keeping the queues so large, I hope to more quickly
> > identify the reason why TCP is actually able to adjust to the immen=
se
> > multipath reordering. What parameters could be highly relevant, oth=
er
> > than the queue size?
> >=20
>=20
> losses of course ;)
>=20
> Real internet is full of packet losses, and probability of these loss=
es
> depends on queue sizes (RED like AQM)
>=20
>=20

BTW, netem in linux-2.6.39 contains lot of changes in netem module

commit 661b79725fea030803a89a16cda
(netem: revised correlated loss generator)

    This is a patch originated with Stefano Salsano and Fabio Ludovici.
    It provides several alternative loss models for use with netem.
    This patch adds two state machine based loss models.
   =20

http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetemCLG



