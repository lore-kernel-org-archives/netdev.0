From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2015-05-28
Date: Thu, 28 May 2015 20:23:23 -0700 (PDT)
Message-ID: <20150528.202323.659007977556925952.davem@davemloft.net>
References: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754784AbbE2DXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 23:23:24 -0400
In-Reply-To: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 28 May 2015 08:25:47 +0200

> 1) Remove xfrm_queue_purge as this is the same as skb_queue_purge.
> 
> 2) Optimize policy and state walk.
> 
> 3) Use a sane return code if afinfo registration fails.
> 
> 4) Only check fori a acquire state if the state is not valid.
> 
> 5) Remove a unnecessary NULL check before xfrm_pol_hold
>    as it checks the input for NULL.
> 
> 6) Return directly if the xfrm hold queue is empty, avoid
>    to take a lock as it is nothing to do in this case.
> 
> 7) Optimize the inexact policy search and allow for matching
>    of policies with priority ~0U.
> 
> All from Li RongQing.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
