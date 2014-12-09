From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2014-12-03
Date: Mon, 08 Dec 2014 21:30:40 -0500 (EST)
Message-ID: <20141208.213040.1485455198588069140.davem@davemloft.net>
References: <1417601101-18625-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbaLICan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 21:30:43 -0500
In-Reply-To: <1417601101-18625-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 3 Dec 2014 11:04:56 +0100

> 1) Fix a set but not used warning. From Fabian Frederick.
> 
> 2) Currently we make sequence number values available to userspace
>    only if we use ESN. Make the sequence number values also available
>    for non ESN states. From Zhi Ding.
> 
> 3) Remove socket policy hashing. We don't need it because socket
>    policies are always looked up via a linked list. From Herbert Xu.
> 
> 4) After removing socket policy hashing, we can use __xfrm_policy_link
>    in xfrm_policy_insert. From Herbert Xu.
> 
> 5) Add a lookup method for vti6 tunnels with wildcard endpoints.
>    I forgot this when I initially implemented vti6.
>    
> Please pull or let me know if there are problems.

Pulled, thanks a lot Steffen.
