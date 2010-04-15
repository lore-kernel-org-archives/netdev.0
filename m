From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 20:32:19 +0800
Message-ID: <s2p412e6f7f1004150532y4b13a0bfgadab3e6f2f4aecd@mail.gmail.com>
References: <1265568122.3688.36.camel@bigi> <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271268242.16881.1719.camel@edumazet-laptop> <1271271222.4567.51.camel@bigi>
	<20100414124426.6aee95c3@nehalam> <1271276568.4567.59.camel@bigi>
	<1271276855.16881.1756.camel@edumazet-laptop> <z2y65634d661004141345o9bdcf759sf266866931823baf@mail.gmail.com>
	<1271278661.16881.1761.camel@edumazet-laptop> <1271333428.23780.3.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, robert@herjulf.net,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:64736 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab0DOMcj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 08:32:39 -0400
Received: by iwn8 with SMTP id 8so561349iwn.16
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 05:32:39 -0700 (PDT)
In-Reply-To: <1271333428.23780.3.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 8:10 PM, jamal <hadi@cyberus.ca> wrote:
> On Wed, 2010-04-14 at 22:57 +0200, Eric Dumazet wrote:
>
>> On my Nehalem machine (16 logical cpus), its NetXtreme II BCM57711E
>> 10Gigabit has 16 queues. It might be good to use less queues accordi=
ng
>> to your results on some workloads, and eventually use RPS on a secon=
d
>> layering.
>

=46or historical reason, we use Linux-2.6.18. Our company have several
products with CPU Xen, P4, or i7. Some of them are SMP, Multi-Core and
Multi-Threaded. We use the similar mechanism like dynamic weighted
RPS. The total throughput is increased nearly linear with the number
of the worker threads(one worker thread per CPU).

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
