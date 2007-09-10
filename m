From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
	low traffic rates
Date: Mon, 10 Sep 2007 08:27:14 -0400
Message-ID: <1189427234.4271.35.camel@localhost>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com>
	 <1189120020.4259.68.camel@localhost>  <46E11A61.9030409@katalix.com>
	 <1189171370.4234.38.camel@localhost>  <46E50C4F.1070506@katalix.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	mandeep.baines@gmail.com, ossthema@de.ibm.com,
	Stephen Hemminger <shemminger@osdl.org>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.229]:62538 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757570AbXIJM1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 08:27:32 -0400
Received: by nz-out-0506.google.com with SMTP id s18so474759nze
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 05:27:24 -0700 (PDT)
In-Reply-To: <46E50C4F.1070506@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-10-09 at 10:20 +0100, James Chapman wrote:
> jamal wrote:
> 
> > If the problem i am trying to solve is "reduce cpu use at lower rate",
> > then this is not the right answer because your cpu use has gone up.
> 
> The problem I'm trying to solve is "reduce the max interrupt rate from 
> NAPI drivers while minimizing latency".

As long as what you are saying above translates to "there is one
interupt per packet per napi poll" then we are saying the same thing.

>  In modern systems, the interrupt 
> rate can be so high that the CPU spends too much time processing 
> interrupts, resulting in the system's behavior seen by the user being 
> degraded.

modern systems also can handle interupts a lot better. 
If you can amortize two packets per interupt per napi poll then you
have done better than the breakeven point; however, I think it is fair
to also disprove that in modern hardware the breakeven point is met with
amortizing two packets.

> Having the poll() called when idle will always increase CPU usage. But 
> the feedback you and others are giving encourages me to find a better 
> compromise. 

i dont mean in any way to discourage you - just making you work
better ;-> It is very refreshing to see that you understand the scope is
performance not vomiting endless versions of code - and for this i feel
obligated to help.

> I'll go away and do some tests. I'll post results here for discussion later.

way to go.

cheers,
jamal

