From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] net/sctp: Eliminate useless code
Date: Wed, 20 Jan 2010 15:03:43 -0800 (PST)
Message-ID: <20100120.150343.236848237.davem@davemloft.net>
References: <Pine.LNX.4.64.1001161657570.28745@ask.diku.dk>
	<4B574702.4040602@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia@diku.dk, sri@us.ibm.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51704
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752472Ab0ATXDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:03:33 -0500
In-Reply-To: <4B574702.4040602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 20 Jan 2010 13:10:10 -0500

> 
> 
> Julia Lawall wrote:
>> From: Julia Lawall <julia@diku.dk>
>> 
>> The variable newinet is initialized twice to the same (side effect-free)
>> expression.  Drop one initialization.
>> 
>> A simplified version of the semantic match that finds this problem is:
>> (http://coccinelle.lip6.fr/)
>> 
>> // <smpl>
>> @forall@
>> idexpression *x;
>> identifier f!=ERR_PTR;
>> @@
>> 
>> x = f(...)
>> ... when != x
>> (
>> x = f(...,<+...x...+>,...)
>> |
>> * x = f(...)
>> )
>> // </smpl>
>> 
>> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Julia,  just like patch #3 this one had the missing final
line of the patch corrupting it, so you'll need to resubmit.
