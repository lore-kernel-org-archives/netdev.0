From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Thu, 22 Apr 2010 09:13:22 +0200
Message-ID: <1271920402.7895.4732.camel@edumazet-laptop>
References: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
	 <1271891149.7895.3751.camel@edumazet-laptop>
	 <j2s412e6f7f1004212333se60a9083s59185ee3466313f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>, jamal <hadi@cyberus.ca>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:55935 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240Ab0DVHNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:13:32 -0400
Received: by bwz25 with SMTP id 25so9162301bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 00:13:31 -0700 (PDT)
In-Reply-To: <j2s412e6f7f1004212333se60a9083s59185ee3466313f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 14:33 +0800, Changli Gao a =C3=A9crit :
> On Thu, Apr 22, 2010 at 7:05 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le mercredi 14 avril 2010 =C3=A0 17:52 +0800, Changli Gao a =C3=A9c=
rit :
> >> batch skb dequeueing from softnet input_pkt_queue
> >>
> >> batch skb dequeueing from softnet input_pkt_queue to reduce potent=
ial lock
> >> contention and irq disabling/enabling.
> >>
> >> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> >> ----
> >
> > lock contention _is_ a problem, Jamal tests can show it.
> >
> > irq disabling/enabling is not, and force to use stop_machine() kill=
er.
> >
>=20
> Although irq_disabling/enabling is not, we should do our best to make
> fast path as quickly as possible, and because stop_machine() is used
> in slow patch, I think we can afford its weight.
>=20
>=20

No thanks, this is out of the question.

Talk to ixiacom guys, some people settle/dismantle dozens of network
device per second, on production machines.




