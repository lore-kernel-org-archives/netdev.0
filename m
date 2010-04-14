From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 21:58:50 +0200
Message-ID: <1271275130.16881.1749.camel@edumazet-laptop>
References: <1265568122.3688.36.camel@bigi>
	 <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	 <1265641748.3688.56.camel@bigi> <1271245986.3943.55.camel@bigi>
	 <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>  <20100414124426.6aee95c3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, Tom Herbert <therbert@google.com>,
	netdev@vger.kernel.org, robert@herjulf.net,
	David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:36755 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469Ab0DNT66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 15:58:58 -0400
Received: by bwz25 with SMTP id 25so664770bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 12:58:56 -0700 (PDT)
In-Reply-To: <20100414124426.6aee95c3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 12:44 -0700, Stephen Hemminger a =C3=A9=
crit :
> On Wed, 14 Apr 2010 14:53:42 -0400
> jamal <hadi@cyberus.ca> wrote:
>=20
> > Agreed. So to enumerate, the benefits come in if:
> > a) you have many processors
> > b) you have single-queue nic
> > c) at sub-threshold traffic you dont care about a little latency
>=20
> There probably needs to be better autotuning for this, there is no re=
ason
> that RPS to be steering packets unless the queue is getting backed up=
=2E
> Some kind of high / low water mark mechanism is needed.
>=20
> RPS might also interact with the core turbo boost functionality on In=
tel chips.
> Newer chips will make a single core faster if other core can be kept =
idle.
>=20
>=20

This was discussed a while ago, and Out Of Order packet delivery was th=
e
thing that frightened us a bit.

Every time we change RPS to be on or off, we might have some extra
noise. Maybe we already have this problem with irqbalance ?



