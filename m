From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 10:50:24 +0800
Message-ID: <l2y412e6f7f1004141950v6db4978azfbf332cf15cf45fa@mail.gmail.com>
References: <1265568122.3688.36.camel@bigi> <1271271222.4567.51.camel@bigi>
	<20100414124426.6aee95c3@nehalam> <1271276568.4567.59.camel@bigi>
	<1271276855.16881.1756.camel@edumazet-laptop> <z2y65634d661004141345o9bdcf759sf266866931823baf@mail.gmail.com>
	<1271278661.16881.1761.camel@edumazet-laptop> <v2s412e6f7f1004141551u5764604h3ab092ee9e70a650@mail.gmail.com>
	<20100414160220.43a62999@nehalam> <1271299206.16881.1764.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Tom Herbert <therbert@google.com>, hadi@cyberus.ca,
	netdev@vger.kernel.org, robert@herjulf.net,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:43781 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756519Ab0DOCup convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 22:50:45 -0400
Received: by pva18 with SMTP id 18so540778pva.19
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 19:50:44 -0700 (PDT)
In-Reply-To: <1271299206.16881.1764.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 10:40 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>
> Agree 100%, and irqbalance is the existing daemon. It should be used =
and
> changed if necessary.
>
> Changli, my stronges argument about your patches is that our schedule=
r
> and memory affinity api (numactl driven) is bitmask oriented, giving =
the
> same weight to individual cpu or individual memory node.
>

It works with the assumption: the workloads handled in non-schedulable
context are less than the others. If most of work is done in
non-schedulable(softirq) context, scheduler can't keep load balance.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
