From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2016-09-08
Date: Thu, 08 Sep 2016 13:10:02 -0700 (PDT)
Message-ID: <20160908.131002.2009251524824942974.davem@davemloft.net>
References: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752833AbcIHUKF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 16:10:05 -0400
In-Reply-To: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 8 Sep 2016 07:54:35 +0200

> 1) Constify the xfrm_replay structures. From Julia Lawall
> 
> 2) Protect xfrm state hash tables with rcu, lookups
>    can be done now without acquiring xfrm_state_lock.
>    From Florian Westphal.
> 
> 3) Protect xfrm policy hash tables with rcu, lookups
>    can be done now without acquiring xfrm_policy_lock.
>    From Florian Westphal.
> 
> 4) We don't need to have a garbage collector list per
>    namespace anymore, so use a global one instead.
>    From Florian Westphal.

Pulled, thanks Steffen.
