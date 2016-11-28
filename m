From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2016-11-25
Date: Sun, 27 Nov 2016 20:22:04 -0500 (EST)
Message-ID: <20161127.202204.566135637255683695.davem@davemloft.net>
References: <1480057080-20177-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751969AbcK1BWG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 20:22:06 -0500
In-Reply-To: <1480057080-20177-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 25 Nov 2016 07:57:57 +0100

> 1) Fix a refcount leak in vti6.
>    From Nicolas Dichtel.
> 
> 2) Fix a wrong if statement in xfrm_sk_policy_lookup.
>    From Florian Westphal.
> 
> 3) The flowcache watermarks are per cpu. Take this into
>    account when comparing to the threshold where we
>    refusing new allocations. From Miroslav Urbanek.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen!
