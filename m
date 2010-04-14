From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 22:27:35 +0200
Message-ID: <1271276855.16881.1756.camel@edumazet-laptop>
References: <1265568122.3688.36.camel@bigi>
	 <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	 <1265641748.3688.56.camel@bigi> <1271245986.3943.55.camel@bigi>
	 <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>  <20100414124426.6aee95c3@nehalam>
	 <1271276568.4567.59.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	robert@herjulf.net, David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:33318 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755619Ab0DNU1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 16:27:43 -0400
Received: by bwz25 with SMTP id 25so703351bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 13:27:41 -0700 (PDT)
In-Reply-To: <1271276568.4567.59.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 16:22 -0400, jamal a =C3=A9crit :
> On Wed, 2010-04-14 at 12:44 -0700, Stephen Hemminger wrote:
>=20
> > RPS might also interact with the core turbo boost functionality on =
Intel chips.
> > Newer chips will make a single core faster if other core can be kep=
t idle.
>=20
> how well does it work with Linux? Sounds like all i need to do is tur=
n
> on some BIOS feature.=20
> One of the negatives with multiqueue nics is because the core selecti=
on
> is static, you could end up overloading one core while others stay id=
le.
> This seems to steal cycle capacity from the idle cores and gives it t=
o
> the busy cpus. nice. So i see it as a boost to multiqueue.

Only if more than one flow is involved.

And if you have many flows, chance they will spread several queues...



