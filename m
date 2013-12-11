From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ipv6: router reachability probing
Date: Wed, 11 Dec 2013 16:03:23 -0500 (EST)
Message-ID: <20131211.160323.283336557694027073.davem@davemloft.net>
References: <d483b5eedcbfedc2002c458b15586679e7795399.1386766078.git.jbenc@redhat.com>
	<20131211191023.GA4675@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab3LKVD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 16:03:26 -0500
In-Reply-To: <20131211191023.GA4675@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 11 Dec 2013 20:10:23 +0100

> On Wed, Dec 11, 2013 at 01:48:20PM +0100, Jiri Benc wrote:
>> RFC 4191 states in 3.5:
>> 
>>    When a host avoids using any non-reachable router X and instead sends
>>    a data packet to another router Y, and the host would have used
>>    router X if router X were reachable, then the host SHOULD probe each
>>    such router X's reachability by sending a single Neighbor
>>    Solicitation to that router's address.  A host MUST NOT probe a
>>    router's reachability in the absence of useful traffic that the host
>>    would have sent to the router if it were reachable.  In any case,
>>    these probes MUST be rate-limited to no more than one per minute per
>>    router.
>> 
>> Currently, when the neighbour corresponding to a router falls into
>> NUD_FAILED, it's never considered again. Introduce a new rt6_nud_state
>> value, RT6_NUD_FAIL_PROBE, which suggests the route should not be used but
>> should be probed with a single NS. The probe is ratelimited by the existing
>> code. To better distinguish meanings of the failure values, rename
>> RT6_NUD_FAIL_SOFT to RT6_NUD_FAIL_DO_RR.
>> 
>> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Looks good, thanks!

Applied, thanks guys.
