From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v4] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 11:32:36 -0700
Message-ID: <4BC8AD44.9050707@hp.com>
References: <alpine.DEB.1.00.1004121651460.31468@pokey.mtv.corp.google.com>	<20100412171205.561a1aec@nehalam>	<o2k65634d661004160851wc00c609p7136a22fd07503c1@mail.gmail.com>	<4BC89F6D.2080604@hp.com> <i2oed628a921004161059z65a3cf1aq5f3cd2194f40a811@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	Ingo Molnar <mingo@elte.hu>
To: Paul Turner <pjt@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:37255 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757978Ab0DPScl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 14:32:41 -0400
In-Reply-To: <i2oed628a921004161059z65a3cf1aq5f3cd2194f40a811@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Even under a hybrid model I think phrasing it as networking leading
> the scheduler here is a little strong.  The scheduler is in both cases
> the most 'informed' place to make these decisions, but I think it
> could benefit from more knowledge.  In the 'virgin' single flow case
> without any steering the network stack is currently able to implicitly
> hint to the scheduler where flows could be most efficiently served due
> to wake-affine balancing behaviors.  This is a natural side-effect of
> wake-ups being sourced by the networking cpus.

Hinting to the scheduler is fine - so long as the final say is the scheduler. 
Presumably it is the thing that knows about the other forces tugging at where to 
run the thread - where its memory is allocated, what other flows are coming to 
it etc.

rick jones
