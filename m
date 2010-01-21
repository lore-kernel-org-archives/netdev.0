From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] net/sctp: Eliminate useless code
Date: Thu, 21 Jan 2010 02:43:37 -0800 (PST)
Message-ID: <20100121.024337.57448535.davem@davemloft.net>
References: <4B574702.4040602@hp.com>
	<20100120.150343.236848237.davem@davemloft.net>
	<Pine.LNX.4.64.1001211121500.13529@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48143
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755203Ab0AUKn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 05:43:28 -0500
In-Reply-To: <Pine.LNX.4.64.1001211121500.13529@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Thu, 21 Jan 2010 11:22:38 +0100 (CET)

> On Wed, 20 Jan 2010, David Miller wrote:
> 
>> From: Vlad Yasevich <vladislav.yasevich@hp.com>
>> Date: Wed, 20 Jan 2010 13:10:10 -0500
>> 
>> > 
>> > 
>> > Julia Lawall wrote:
>> >> From: Julia Lawall <julia@diku.dk>
>> >> 
>> >> The variable newinet is initialized twice to the same (side effect-free)
>> >> expression.  Drop one initialization.
>> >> 
>> >> A simplified version of the semantic match that finds this problem is:
>> >> (http://coccinelle.lip6.fr/)
>> >> 
>> >> // <smpl>
>> >> @forall@
>> >> idexpression *x;
>> >> identifier f!=ERR_PTR;
>> >> @@
>> >> 
>> >> x = f(...)
>> >> ... when != x
>> >> (
>> >> x = f(...,<+...x...+>,...)
>> >> |
>> >> * x = f(...)
>> >> )
>> >> // </smpl>
>> >> 
>> >> Signed-off-by: Julia Lawall <julia@diku.dk>
>> > 
>> > Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
>> 
>> Julia,  just like patch #3 this one had the missing final
>> line of the patch corrupting it, so you'll need to resubmit.
> 
> I have generated and sent it again, but this time I don't see the problem.  
> If there is still a problem, perhaps you could send me back the patch you 
> received?

You dropped Vlad' ACK in your re-submission.

I'll fix it up this time, but please accumulate ACK's when
resubmitting patches merely for the purpose of fixing some
technical submission problem.

Thanks.
