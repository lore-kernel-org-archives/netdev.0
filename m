From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2013-10-09
Date: Wed, 09 Oct 2013 13:44:01 -0400 (EDT)
Message-ID: <20131009.134401.2108436834464148316.davem@davemloft.net>
References: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49906 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756968Ab3JIRoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 13:44:04 -0400
In-Reply-To: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed,  9 Oct 2013 12:59:04 +0200

> 1) We used the wrong netlink attribute to verify the
>    lenght of the replay window on async events. Fix this by
>    using the right netlink attribute.
> 
> 2) Policy lookups can not match the output interface on forwarding.
>    Add the needed informations to the flow informations.
> 
> 3) We update the pmtu when we receive a ICMPV6_DEST_UNREACH message
>    on IPsec with ipv6. This is wrong and leads to strange fragmented
>    packets, only ICMPV6_PKT_TOOBIG messages should update the pmtu.
>    Fix this by removing the ICMPV6_DEST_UNREACH check from the IPsec
>    protocol error handlers.
> 
> 4) The legacy IPsec anti replay mechanism supports anti replay
>    windows up to 32 packets. If a user requests for a bigger
>    anti replay window, we use 32 packets but pretend that we use
>    the requested window size. Fix from Fan Du.
> 
> 5) If asynchronous events are enabled and replay_maxdiff is set to
>    zero, we generate an async event for every received packet instead
>    of checking whether a timeout occurred. Fix from Thomas Egerer.
> 
> 6) Policies need a refcount when the state resolution timer is armed.
>    Otherwise the timer can fire after the policy is deleted.
> 
> 7) We might dreference a NULL pointer if the hold_queue is empty,
>    add a check to avoid this.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot Steffen.
