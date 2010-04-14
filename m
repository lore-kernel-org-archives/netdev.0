From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 22:57:41 +0200
Message-ID: <1271278661.16881.1761.camel@edumazet-laptop>
References: <1265568122.3688.36.camel@bigi>
	 <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	 <1265641748.3688.56.camel@bigi> <1271245986.3943.55.camel@bigi>
	 <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi> <20100414124426.6aee95c3@nehalam>
	 <1271276568.4567.59.camel@bigi>
	 <1271276855.16881.1756.camel@edumazet-laptop>
	 <z2y65634d661004141345o9bdcf759sf266866931823baf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, robert@herjulf.net,
	David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:56345 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756105Ab0DNU5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 16:57:52 -0400
Received: by bwz1 with SMTP id 1so962183bwz.2
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 13:57:49 -0700 (PDT)
In-Reply-To: <z2y65634d661004141345o9bdcf759sf266866931823baf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 13:45 -0700, Tom Herbert a =C3=A9crit =
:
> > Only if more than one flow is involved.
> >
> > And if you have many flows, chance they will spread several queues.=
=2E.
> >
>=20
> But use too many queues and the efficiency of NAPI drops and cost of
> device interrupts becomes dominant, so that the overhead from
> additional hard interrupts can surpass the overhead of doing RPS and
> the IPIs.  I believe we are seeing this is in some of our results
> which shows that a combination of multi-queue and RPS can be better
> than just multi-queue (see rps changelog).  Again, I'm not claiming
> that is generally true, but there are a lot of factors to consider.
> --

RPS can be tuned (Changli wants a finer tuning...), it would be
intereting to tune multiqueue devices too. I dont know if its possible
right now.

On my Nehalem machine (16 logical cpus), its NetXtreme II BCM57711E
10Gigabit has 16 queues. It might be good to use less queues according
to your results on some workloads, and eventually use RPS on a second
layering.




