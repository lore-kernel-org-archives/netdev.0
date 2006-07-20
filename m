From: Ben Greear <greearb@candelatech.com>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Thu, 20 Jul 2006 14:21:57 -0700
Message-ID: <44BFF3F5.3040104@candelatech.com>
References: <20060719131915.GA21942@ms2.inr.ac.ru> <20060720073223.GA15567@tservice.net.ru> <20060720164100.GA9213@ms2.inr.ac.ru> <20060720210849.GA28715@tservice.net.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:61581 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1030378AbWGTVWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 17:22:30 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060720210849.GA28715@tservice.net.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:

>>Backlog is actually not a protection, but a thing equivalent to netchannel.
>>The difference is only that it tries to process something immediately,
>>when it is safe. You can omit this and push everything to backlog(=netchannel),
>>which is processed only by syscalls, if you do not care about latency.
> 
> 
> If we consider netchannels as how Van Jackobson discribed them, then
> mutext is not needed, since it is impossible to have several readers or
> writers. But in socket case even if there is only one userspace
> consumer, that lock must be held to protect against bh (or introduce
> several queues and complicate a lot their's management (ucopy for
> example)).

Out of curiosity, is it possible to have the single producer logic
if you have two+ ethernet interfaces handling frames for a single
TCP connection?  (I am assuming some sort of multi-path routing
logic...)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

