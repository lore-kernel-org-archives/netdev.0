From: Rick Jones <rick.jones2@hp.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 09:41:18 -0700
Message-ID: <4BC741AE.3000108@hp.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>	<1271268242.16881.1719.camel@edumazet-laptop>	<1271271222.4567.51.camel@bigi>	<20100415.014857.168270765.davem@davemloft.net> <1271332528.4567.150.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	therbert@google.com, netdev@vger.kernel.org, robert@herjulf.net,
	xiaosuo@gmail.com, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:6112 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801Ab0DOQlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 12:41:23 -0400
In-Reply-To: <1271332528.4567.150.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> I speculate again that it may be too costly to run rps on something like
> a tigerton or intel clovertown where you have cores sharing/contending
> for an FSB. If I can get answers to the question: "What h/ware are
> people running?" i could be proven wrong.
> [Note: I am not against RPS - i think it has its place; so i hope my
> desire to find out when to use rps doesnt show as hostility towards
> rps.]

IPS (~= RPS) was running on shared FSB HP9000's.  Now, that was also a BSD 
networking stack with netisrq's and the like.  TOPS (~= RFS) was also run on 
shared FSB HP9000s, as well as CC-NUMA HP9000s and Integrity systems.  TOPS was 
implemented in a Streams-based stack tracing its history to a common ancestor 
with Solaris (Mentat).

rick jones
