From: Wenji Wu <wenji@fnal.gov>
Subject: RE: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 11:04:00 -0600
Message-ID: <HNEBLGGMEGLPMPPDOPMGAEANCGAA.wenji@fnal.gov>
References: <20061130103240.GA25733@elte.hu>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
	David Miller <davem@davemloft.net>, akpm@osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:29589 "EHLO mailgw1.fnal.gov")
	by vger.kernel.org with ESMTP id S1030731AbWK3REF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 12:04:05 -0500
In-reply-to: <20061130103240.GA25733@elte.hu>
To: Ingo Molnar <mingo@elte.hu>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>The solution is really simple and needs no kernel change at all: if you
>want the TCP receiver to get a larger share of timeslices then either
>renice it to -20 or renice the other tasks to +19.

Simply give a larger share of timeslices to the TCP receiver won't solve the
problem.  No matter what the timeslice is, if the TCP receiving process has
packets within backlog, and the process is expired and moved to the expired
array, RTO might happen in the TCP sender.

The solution does not look like that simple.

wenji




