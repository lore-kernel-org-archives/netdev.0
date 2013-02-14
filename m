From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2013-02-14
Date: Thu, 14 Feb 2013 13:30:45 -0500 (EST)
Message-ID: <20130214.133045.921192511470923993.davem@davemloft.net>
References: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760806Ab3BNSar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 13:30:47 -0500
In-Reply-To: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 14 Feb 2013 12:47:20 +0100

> 1) Remove a duplicated call to skb_orphan() in pf_key, from Cong Wang.
> 
> 2) Prepare xfrm and pf_key for algorithms without pf_key support,
>    from Jussi Kivilinna.
> 
> 3) Fix an unbalanced lock in xfrm_output_one(), from Li RongQing.
> 
> 4) Add an IPsec state resolution packet queue to handle
>    packets that are send before the states are resolved.
> 
> 5) xfrm4_policy_fini() is unused since 2.6.11, time to remove it.
>    From Michal Kubecek.
> 
> 6) The xfrm gc threshold was configurable just in the initial
>    namespace, make it configurable in all namespaces. From
>    Michal Kubecek.
> 
> 7) We currently can not insert policies with mark and mask
>    such that some flows would be matched from both policies.
>    Allow this if the priorities of these policies are different,
>    the one with the higher priority is used in this case.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
