From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Detecting TCP loss on the receiving side?
Date: Thu, 10 Jul 2008 14:20:07 -0700
Message-ID: <48767D07.2000003@hp.com>
References: <4876668C.8040108@limebrokerage.com> <48766CF0.1020101@hp.com>	<48766EC2.2090000@limebrokerage.com> <1e41a3230807101405y437dff4er443185be3228caa5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Dan_No=E9?= <dnoe@limebrokerage.com>,
	netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:41032 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbYGJVUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 17:20:51 -0400
In-Reply-To: <1e41a3230807101405y437dff4er443185be3228caa5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Heffner wrote:
> Looking for loss at the receiver is a bit tricky.  It doesn't look
> like struct tcp_info has enough information to do this easily.  If you
> are able to install a custom kernel on this machine, the Web100 patch
> would be able to gather enough information to figure it out.  The
> basic idea would be to look for a difference between RcvNxt and
> RcvMax.

And even then it depends on the connections having multiple segments in 
flight at one time.  Although I suppose that cuts both ways and affects 
the tracing too, but perhaps not to the same extent.

Dan - seeing "brokerage" in your email and worries about latency makes 
me think that your app(s) are pushing around lots of small messages - 
are those spread-out across lots of connections, or are they 
consolidated into a rather smaller number of connections?  Also, what is 
the magnitude of the latency in these latency events?

rick jones
