From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2014-02-24
Date: Mon, 24 Feb 2014 18:17:55 -0500 (EST)
Message-ID: <20140224.181755.1278751544217103372.davem@davemloft.net>
References: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48259 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbaBXXR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 18:17:57 -0500
In-Reply-To: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 24 Feb 2014 10:59:48 +0100

> 1) Introduce skb_to_sgvec_nomark function to add further data to the sg list
>    without calling sg_unmark_end first. Needed to add extended sequence
>    number informations. From Fan Du.
> 
> 2) Add IPsec extended sequence numbers support to the Authentication Header
>    protocol for ipv4 and ipv6. From Fan Du.
> 
> 3) Make the IPsec flowcache namespace aware, from Fan Du.
> 
> 4) Avoid creating temporary SA for every packet when no key manager is
>    registered. From Horia Geanta.
> 
> 5) Support filtering of SA dumps to show only the SAs that match a
>    given filter. From Nicolas Dichtel.
> 
> 6) Remove caching of xfrm_policy_sk_bundles. The cached socket policy bundles
>    are never used, instead we create a new cache entry whenever xfrm_lookup()
>    is called on a socket policy. Most protocols cache the used routes to the
>    socket, so this caching is not needed.
> 
> 7)  Fix a forgotten SADB_X_EXT_FILTER length check in pfkey, from Nicolas
>     Dichtel.
> 
> 8) Cleanup error handling of xfrm_state_clone.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot Steffen.
