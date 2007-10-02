From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 15:17:35 -0700
Message-ID: <4702C37F.4030601@hp.com>
References: <20071002164858.GH17418@bitmover.com>	<20071002.141656.42880006.davem@davemloft.net>	<20071002212608.GG29944@bitmover.com> <20071002.144709.123999983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lm@bitmover.com, torvalds@linux-foundation.org,
	herbert@gondor.apana.org.au, wscott@bitmover.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:37113 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753146AbXJBWRh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 18:17:37 -0400
In-Reply-To: <20071002.144709.123999983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: lm@bitmover.com (Larry McVoy)
> Date: Tue, 2 Oct 2007 14:26:08 -0700
> 
> 
>>And note that sky2 doesn't have this problem.  Does the broadcom do TSO?
>>And sky2 not?  I noticed a much higher CPU load for sky2.
> 
> 
> Yes the broadcoms (the revisions I have) do TSO and it is enabled
> on both sides.
> 
> Which makes the mis-matched performance even stranger :)

Stranger still, with a mix of a 2.6.23-rc5ish kernel and a net-2.6.24 one 
(pulled oh middle of last week?) I get link-rate and I see no asymmetry between 
TCP_STREAM and TCP_MAERTS over an "e1000" link with no switch or tg3 with a 
ProCurve on my rx2660's.

I can also run bw_tcp from lmbench 3.0a8 and get 106 MB/s.

I don't have a netgear switch to try in all this...

rick jones
