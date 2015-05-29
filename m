From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2015-05-28
Date: Thu, 28 May 2015 20:41:52 -0700 (PDT)
Message-ID: <20150528.204152.723928818590100061.davem@davemloft.net>
References: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838AbbE2Dlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 23:41:53 -0400
In-Reply-To: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 28 May 2015 09:28:03 +0200

> 1) Fix a race in xfrm_state_lookup_byspi, we need to take
>    the refcount before we release xfrm_state_lock.
>    From Li RongQing.
> 
> 2) Fix IV generation on ESN state. We used just the
>    low order sequence numbers for IV generation on
>    ESN, as a result the IV can repeat on the same
>    state. Fix this by using the  high order sequence
>    number bits too and make sure to always initialize
>    the high order bits with zero. These patches are
>    serious stable candidates. Fixes from Herbert Xu.
> 
> 3) Fix the skb->mark handling on vti. We don't
>    reset skb->mark in skb_scrub_packet anymore,
>    so vti must care to restore the original
>    value back after it was used to lookup the
>    vti policy and state. Fixes from Alexander Duyck.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
