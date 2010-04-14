From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 06:51:29 +0800
Message-ID: <v2s412e6f7f1004141551u5764604h3ab092ee9e70a650@mail.gmail.com>
References: <1265568122.3688.36.camel@bigi> <1271245986.3943.55.camel@bigi>
	<t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271268242.16881.1719.camel@edumazet-laptop> <1271271222.4567.51.camel@bigi>
	<20100414124426.6aee95c3@nehalam> <1271276568.4567.59.camel@bigi>
	<1271276855.16881.1756.camel@edumazet-laptop> <z2y65634d661004141345o9bdcf759sf266866931823baf@mail.gmail.com>
	<1271278661.16881.1761.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, hadi@cyberus.ca,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, robert@herjulf.net,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:57537 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757035Ab0DNWvu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 18:51:50 -0400
Received: by gyg13 with SMTP id 13so333359gyg.19
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 15:51:49 -0700 (PDT)
In-Reply-To: <1271278661.16881.1761.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 4:57 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> RPS can be tuned (Changli wants a finer tuning...), it would be
> intereting to tune multiqueue devices too. I dont know if its possibl=
e
> right now.
>
> On my Nehalem machine (16 logical cpus), its NetXtreme II BCM57711E
> 10Gigabit has 16 queues. It might be good to use less queues accordin=
g
> to your results on some workloads, and eventually use RPS on a second
> layering.

My idear is: run a daemon in userland to monitor the softnet
statistics, and tun the RPS setting if necessary. It seems that the
current softnet statistics data isn't correct.

Long time ago, I did a test, and the conclution was
call_function_single IPI was more expensive than resched IPI, so I
moved to kernel thread from softirq for packet processing. I'll redo
the test later.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
