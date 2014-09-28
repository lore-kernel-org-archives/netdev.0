From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2014-09-25
Date: Sun, 28 Sep 2014 17:19:40 -0400 (EDT)
Message-ID: <20140928.171940.2099036190053990256.davem@davemloft.net>
References: <1411636225-4433-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaI1VTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 17:19:41 -0400
In-Reply-To: <1411636225-4433-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 25 Sep 2014 11:10:21 +0200

> 1) Remove useless hash_resize_mutex in xfrm_hash_resize().
>    This mutex is used only there, but xfrm_hash_resize()
>    can't be called concurrently at all. From Ying Xue.
> 
> 2) Extend policy hashing to prefixed policies based on
>    prefix lenght thresholds. From Christophe Gouault.
> 
> 3) Make the policy hash table thresholds configurable
>    via netlink. From Christophe Gouault.
> 
> 4) Remove the maximum authentication length for AH.
>    This was needed to limit stack usage. We switched
>    already to allocate space, so no need to keep the
>    limit. From Herbert Xu.

Pulled, thanks a lot Steffen.
