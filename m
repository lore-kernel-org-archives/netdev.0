From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 21:54:28 +0100
Message-ID: <20061130205428.GA21140@elte.hu>
References: <20061130103240.GA25733@elte.hu> <20061130.122258.68041055.davem@davemloft.net> <20061130203026.GD14696@elte.hu> <20061130.123853.10298783.davem@davemloft.net> <20061130204908.GA19393@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, nickpiggin@yahoo.com.au, wenji@fnal.gov,
	akpm@osdl.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:9413 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1031458AbWK3UzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 15:55:07 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061130204908.GA19393@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> [...] Instead what i'd like to see is more TCP performance (and a 
> nicer over-the-wire behavior - no retransmits for example) /with the 
> same 10% CPU time used/. Are we in rough agreement?

put in another way: i'd like to see the "TCP bytes transferred per CPU 
time spent by the TCP stack" ratio to be maximized in a load-independent 
way (part of which is the sender host too: to not cause unnecessary 
retransmits is important as well). In a high-load scenario this means 
that any measure that purely improves TCP throughput by giving it more 
cycles is not a real improvement. So the focus should be on throttling 
intelligently and without causing extra work on the sender side either - 
not on trying to circumvent throttling measures.

	Ingo
