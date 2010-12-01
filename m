From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 01 Dec 2010 08:47:29 +0100
Message-ID: <1291189649.2856.478.camel@edumazet-laptop>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
	 <1291109699.2904.11.camel@edumazet-laptop>
	 <AANLkTi=VpmnrXTBNV7McQm6mq9ULT7KTKbM8_hLPoL=2@mail.gmail.com>
	 <1291127670.2904.96.camel@edumazet-laptop>
	 <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
	 <AANLkTimynbhgo2dqFwKOc8NT9TXpkCtCJMvwkySEBORz@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rui <wirelesser@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59908 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418Ab0LAHvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 02:51:10 -0500
Received: by wwa36 with SMTP id 36so7060452wwa.1
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 23:51:09 -0800 (PST)
In-Reply-To: <AANLkTimynbhgo2dqFwKOc8NT9TXpkCtCJMvwkySEBORz@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 15:36 +0800, Changli Gao a =C3=
=A9crit :
> On Wed, Dec 1, 2010 at 11:48 AM, Rui <wirelesser@gmail.com> wrote:
> > one more question is
> >
> > if  RPS can spread the load into 4 separate cpus, how about the
> > "packet_rcv(or tpacket_rcv)" ? will they run in parallel?
> >
>=20
> You mentioned RPS. But the current bpf doesn't have an instruction to
> get the current CPU number. You can try this patch attached.
>=20
> Maybe we can leverage the bpf and SO_REUSEPORT to direct the traffic
> to the socket instance on the local CPU.
>=20

Oh well, it seems you read over my neck, I was preparing a patch with
SKF_AD_RXHASH and SKF_AD_CPU




