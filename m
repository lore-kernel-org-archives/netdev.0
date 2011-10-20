From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] pktgen: bug when calling ndelay in x86 architectures
Date: Thu, 20 Oct 2011 15:44:13 +0200
Message-ID: <1319118253.7735.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E9D5E1B.3080704@gmail.com>
	   <1318939007.2657.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	   <1318946401.23980.6.camel@deadeye>
	  <1318949264.2657.97.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <4E9E9963.7090209@gmail.com> <1319019235.3103.10.camel@edumazet-laptop>
	 <4EA020B3.4030208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Voravit Tanyingyong <voravit@kth.se>,
	Jens Laas <jens.laas@uadm.uu.se>
To: Daniel Turull <daniel.turull@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55074 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab1JTNoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 09:44:19 -0400
Received: by wyg36 with SMTP id 36so2886585wyg.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 06:44:18 -0700 (PDT)
In-Reply-To: <4EA020B3.4030208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 octobre 2011 =C3=A0 15:22 +0200, Daniel Turull a =C3=A9crit=
 :
> Hi,
>=20
> I tested the patch and it works well.
>=20

Thanks !


>=20
> I think if we increase the constant to 1ms, we will reduce the jitter=
 if we have
> a rate between 1kpps and 10 kpps, but I guess is not a big deal.
>=20


> I've plot this new graph with this patch:
> http://tslab.ssvl.kth.se/pktgen/img/inter_eric1.eps

Unfortunately, the sender cpu might be preempted by timer irq or other
expensive irq, so the Min/Max values are not very different I guess.

I dont understand your Min values.

At 100 pps, how is it possible to have a Min value of ~5000 ns ?
