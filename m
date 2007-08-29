From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 16:06:27 -0700
Message-ID: <46D5FBF3.5050700@hp.com>
References: <5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>	<20070829.144656.104048365.davem@davemloft.net>	<46D5F32F.2070502@hp.com> <20070829.153503.18295527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:40922 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757876AbXH2XGo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 19:06:44 -0400
In-Reply-To: <20070829.153503.18295527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> All of this seems to suggest that the RTO calculation is wrong.

That is a possiblity.  Or at least could be enhanced.

> It seems that packets in this network can be delayed several orders of
> magnitude longer than the usual round trip as measured by TCP.
> 
> What exactly causes such a huge delay?  What is the TCP measured RTO
> in these circumstances where spurious RTOs happen and a 3 second
> minimum RTO makes things better?

I belive the biggest component comes from link-layer retransmissions. 
There can also be some short outtages thanks to signal blocking, 
tunnels, people with big hats and whatnot that the link-layer 
retransmissions are trying to address.  The three seconds seems to be a 
value that gives the certainty that 99 times out of 10 the segment was 
indeed lost.

The trace I've been sent shows clean RTTs ranging from ~200 milliseconds 
to ~7000 milliseconds.

rick

