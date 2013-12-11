From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next] ipv6: router reachability probing
Date: Wed, 11 Dec 2013 20:10:23 +0100
Message-ID: <20131211191023.GA4675@order.stressinduktion.org>
References: <d483b5eedcbfedc2002c458b15586679e7795399.1386766078.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48901 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084Ab3LKTKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 14:10:24 -0500
Content-Disposition: inline
In-Reply-To: <d483b5eedcbfedc2002c458b15586679e7795399.1386766078.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 01:48:20PM +0100, Jiri Benc wrote:
> RFC 4191 states in 3.5:
> 
>    When a host avoids using any non-reachable router X and instead sends
>    a data packet to another router Y, and the host would have used
>    router X if router X were reachable, then the host SHOULD probe each
>    such router X's reachability by sending a single Neighbor
>    Solicitation to that router's address.  A host MUST NOT probe a
>    router's reachability in the absence of useful traffic that the host
>    would have sent to the router if it were reachable.  In any case,
>    these probes MUST be rate-limited to no more than one per minute per
>    router.
> 
> Currently, when the neighbour corresponding to a router falls into
> NUD_FAILED, it's never considered again. Introduce a new rt6_nud_state
> value, RT6_NUD_FAIL_PROBE, which suggests the route should not be used but
> should be probed with a single NS. The probe is ratelimited by the existing
> code. To better distinguish meanings of the failure values, rename
> RT6_NUD_FAIL_SOFT to RT6_NUD_FAIL_DO_RR.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good, thanks!
