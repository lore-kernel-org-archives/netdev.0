From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 08:10:28 -0400
Message-ID: <1271333428.23780.3.camel@bigi>
References: <1265568122.3688.36.camel@bigi>
	 <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	 <1265641748.3688.56.camel@bigi> <1271245986.3943.55.camel@bigi>
	 <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi> <20100414124426.6aee95c3@nehalam>
	 <1271276568.4567.59.camel@bigi>
	 <1271276855.16881.1756.camel@edumazet-laptop>
	 <z2y65634d661004141345o9bdcf759sf266866931823baf@mail.gmail.com>
	 <1271278661.16881.1761.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, robert@herjulf.net,
	David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f189.google.com ([209.85.221.189]:43358 "EHLO
	mail-qy0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab0DOMKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 08:10:36 -0400
Received: by qyk27 with SMTP id 27so1545446qyk.23
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 05:10:35 -0700 (PDT)
In-Reply-To: <1271278661.16881.1761.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-14 at 22:57 +0200, Eric Dumazet wrote:

> On my Nehalem machine (16 logical cpus), its NetXtreme II BCM57711E
> 10Gigabit has 16 queues. It might be good to use less queues according
> to your results on some workloads, and eventually use RPS on a second
> layering.

Ok Eric, you seem to be running a system with two Nehalems
interconnected by QPI.
Is there any difference, performance-wise, between redirecting from
coreX to coreY when they are on the same Nehalem vs when you
are going across QPI?

cheers,
jamal

