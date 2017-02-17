From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2017-02-16
Date: Thu, 16 Feb 2017 22:05:57 -0500 (EST)
Message-ID: <20170216.220557.990082216928137722.davem@davemloft.net>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754461AbdBQDGA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 22:06:00 -0500
In-Reply-To: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 16 Feb 2017 13:18:34 +0100

> 1) Make struct xfrm_input_afinfo const, nothing writes to it.
>    From Florian Westphal.
> 
> 2) Remove all places that write to the afinfo policy backend
>    and make the struct const then.
>    From Florian Westphal.
> 
> 3) Prepare for packet consuming gro callbacks and add
>    ESP GRO handlers. ESP packets can be decapsulated
>    at the GRO layer then. It saves a round through
>    the stack for each ESP packet.
> 
> 
> Please note that this has a merge coflict between commit
> 
> 63fca65d0863 ("net: add confirm_neigh method to dst_ops")
> 
> from net-next and
> 
> 3d7d25a68ea5 ("xfrm: policy: remove garbage_collect callback")
> a2817d8b279b ("xfrm: policy: remove family field")
> 
> from ipsec-next.
> 
> The conflict can be solved as it is done in linux-next.
> 
> Please pull or let me know if there are problems.

Pulled, thanks.  Please double check that I did the merge conflict
resolution properly.
