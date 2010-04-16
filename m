From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v4] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 10:33:33 -0700
Message-ID: <4BC89F6D.2080604@hp.com>
References: <alpine.DEB.1.00.1004121651460.31468@pokey.mtv.corp.google.com>	<20100412171205.561a1aec@nehalam> <o2k65634d661004160851wc00c609p7136a22fd07503c1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:10744 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352Ab0DPRdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 13:33:36 -0400
In-Reply-To: <o2k65634d661004160851wc00c609p7136a22fd07503c1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> This is true.  There is a fundamental question of whether scheduler
> should lead networking or vice versa.  The advantages of networking
> following scheduler seem to become more apparent on heavily loaded
> systems or with threads that handle more than one flow.

I will confess to being in the networking should follow the scheduler camp :)

> I'm not sure these two models have to be mutually exclusive, we are
> looking at some ways to make a hybrid model.

It is perhaps too speculative on my part, but if the host has no control over 
the remote addressing of the connections to/from it, doesn't that suggest that 
allowing networking to lead the scheduler gives "external forces" more say in 
intra-system resource consumption than we might want them to have?

rick jones
