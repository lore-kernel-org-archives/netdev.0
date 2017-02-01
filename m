From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2017-02-01
Date: Wed, 01 Feb 2017 11:38:47 -0500 (EST)
Message-ID: <20170201.113847.394056137617535611.davem@davemloft.net>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38328 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbdBAQiv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 11:38:51 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 1 Feb 2017 09:17:42 +0100

> 1) Some typo fixes, from Alexander Alemayhu.
> 
> 2) Don't acquire state lock in get_mtu functions.
>    The only rece against a dead state does not matter.
>    From Florian Westphal.
> 
> 3) Remove xfrm4_state_fini, it is unused for more than
>    10 years. From Florian Westphal.
> 
> 4) Various rcu usage improvements. From Florian Westphal.
> 
> 5) Properly handle crypto arrors in ah4/ah6.
>    From Gilad Ben-Yossef.
> 
> 6) Try to avoid skb linearization in esp4 and esp6.
> 
> 7) The esp trailer is now set up in different places,
>    add a helper for this.
> 
> 8) With the upcomming usage of gro_cells in IPsec,
>    a gro merged skb can have a secpath. Drop it
>    before freeing or reusing the skb.
> 
> 9) Add a xfrm dummy network device for napi. With
>    this we can use gro_cells from within xfrm,
>    it allows IPsec GRO without impact on the generic
>    networking code.
> 
> Please pull or let me know if there are problems.

Looks great, pulled, thanks a lot!
