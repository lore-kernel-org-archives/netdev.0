From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Wed, 13 Jun 2012 23:54:25 -0700 (PDT)
Message-ID: <20120613.235425.582674313518085400.davem@davemloft.net>
References: <20120613.224203.297717896085583687.davem@davemloft.net>
	<20120613.225941.2175393318277942399.davem@davemloft.net>
	<20120614063632.GS27795@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766Ab2FNGy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 02:54:28 -0400
In-Reply-To: <20120614063632.GS27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 14 Jun 2012 08:36:32 +0200

> On Wed, Jun 13, 2012 at 10:59:41PM -0700, David Miller wrote:
>> 
>> Actually, thinking some more, we could extend my inet->pmtudisc patch
>> to achieve a similar effect.
>> 
>> Essentially we'd have a socket local PMTU value for datagram sockets.
>> 
>> Would you be OK with that approach?
> 
> This would require to maintain socket local pmtu expire times too.
> Also, which of these pmtu values do we report if a user asks for
> that? And how should we flush all these pmtu values?
> 
> It could have some side effects. But if we get it to work,
> it would be an improvement. I'm fine with everything
> that works in the end :-)

Your right, maybe the route updating approach is therefore better.

I'll play around with my original patch.

Thanks.
