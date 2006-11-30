From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 21:20:34 +0100
Message-ID: <20061130202034.GB14696@elte.hu>
References: <20061130103240.GA25733@elte.hu> <HNEBLGGMEGLPMPPDOPMGAEANCGAA.wenji@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	David Miller <davem@davemloft.net>, akpm@osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:52965 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1031343AbWK3UVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 15:21:08 -0500
To: Wenji Wu <wenji@fnal.gov>
Content-Disposition: inline
In-Reply-To: <HNEBLGGMEGLPMPPDOPMGAEANCGAA.wenji@fnal.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Wenji Wu <wenji@fnal.gov> wrote:

> >The solution is really simple and needs no kernel change at all: if 
> >you want the TCP receiver to get a larger share of timeslices then 
> >either renice it to -20 or renice the other tasks to +19.
> 
> Simply give a larger share of timeslices to the TCP receiver won't 
> solve the problem.  No matter what the timeslice is, if the TCP 
> receiving process has packets within backlog, and the process is 
> expired and moved to the expired array, RTO might happen in the TCP 
> sender.

if you still have the test-setup, could you nevertheless try setting the 
priority of the receiving TCP task to nice -20 and see what kind of 
performance you get?

	Ingo
