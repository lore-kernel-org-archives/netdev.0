From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 09:27:35 -0400
Message-ID: <1271424455.4606.39.camel@bigi>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi> <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <o2v412e6f7f1004152302j1aca5edam9d53d01781ddbe9d@mail.gmail.com>
	 <20100416071522.GY18855@one.firstfloor.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f196.google.com ([209.85.221.196]:56908 "EHLO
	mail-qy0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120Ab0DPN1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 09:27:48 -0400
Received: by qyk34 with SMTP id 34so3279429qyk.22
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 06:27:47 -0700 (PDT)
In-Reply-To: <20100416071522.GY18855@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-04-16 at 09:15 +0200, Andi Kleen wrote:

> > resched IPI, apparently. But it is async absolutely. and its IRQ
> > handler is lighter.
> 
> It shouldn't be a lot lighter than the new fancy "queued smp_call_function"
> that's in the tree for a few releases. So it would surprise me if it made
> much difference. In the old days when there was only a single lock for
> s_c_f() perhaps...

So you are saying that the old implementation of IPI (likely what i
tried pre-napi and as recent as 2-3 years ago) was bad because of a
single lock?

BTW, I directed some questions to you earlier but didnt get a response,
to quote:
---
On IPIs:
Is anyone familiar with what is going on with Nehalem? Why is it this
good? I expect things will get a lot nastier with other hardware like
xeon based or even Nehalem with rps going across QPI.
Here's why i think IPIs are bad, please correct me if i am wrong:
- they are synchronous. i.e an IPI issuer has to wait for an ACK (which
is in the form of an IPI).
- data cache has to be synced to main memory
- the instruction pipeline is flushed
- what else did i miss? Andi?
---

Do you know any specs i could read up which will tell me a little more?

cheers,
jamal


