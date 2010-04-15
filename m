From: Rick Jones <rick.jones2@hp.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Thu, 15 Apr 2010 13:25:26 -0700
Message-ID: <4BC77636.5060506@hp.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>	<1271268242.16881.1719.camel@edumazet-laptop>	<1271271222.4567.51.camel@bigi>	<20100415.014857.168270765.davem@davemloft.net>	<1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com> <1271362581.23780.12.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	therbert@google.com, netdev@vger.kernel.org, robert@herjulf.net,
	xiaosuo@gmail.com, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:39106 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756564Ab0DOUZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 16:25:29 -0400
In-Reply-To: <1271362581.23780.12.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Thu, 2010-04-15 at 09:41 -0700, Rick Jones wrote:
> 
> 
>>IPS (~= RPS) was running on shared FSB HP9000's.  Now, that was also a BSD 
>>networking stack with netisrq's and the like.  TOPS (~= RFS) was also run on 
>>shared FSB HP9000s, as well as CC-NUMA HP9000s and Integrity systems.  TOPS was 
>>implemented in a Streams-based stack tracing its history to a common ancestor 
>>with Solaris (Mentat).
> 
> 
> Sounds interesting.
> Wikipedia information overload. Any arch description of the HP9000? 

I should have been more specific - HP 9000 Model 800's :) PA-RISC based business 
computers running HP-UX.  In the case of IPS, HP-UX 10.20 ca 1995 or so.

> Did your scheme use IPIs to message the other CPUs?

Netisrs were kernel processes one per CPU (back then a core, a processor and a 
CPU were one and the same :), and while we didn't call them IPI's, yes, it was a 
"soft interrupt" directed at the given processor to launch the netisr if it 
wasn't already running.

TOPS was similar, but was with Streams and that did/does have some kernel 
processes not everything would happen as a kernel process.

rick jones

HP 3000 Model 900's - by and large the same PA-RISC hardware but running MPE/XL 
(later called MPE/iX)
HP 9000 Model 700's - PA-RISC based workstations
HP 9000 Model 300's - Moto 68K-based workstations (replaced by the 700s)
