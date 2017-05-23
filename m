From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2017-05-23
Date: Tue, 23 May 2017 10:54:21 -0400 (EDT)
Message-ID: <20170523.105421.498858429985702866.davem@davemloft.net>
References: <1495517624-27096-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35784 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968285AbdEWOy0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:54:26 -0400
In-Reply-To: <1495517624-27096-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 23 May 2017 07:33:39 +0200

> 1) Fix wrong header offset for esp4 udpencap packets.
> 
> 2) Fix a stack access out of bounds when creating a bundle
>    with sub policies. From Sabrina Dubroca.
> 
> 3) Fix slab-out-of-bounds in pfkey due to an incorrect
>    sadb_x_sec_len calculation.
> 
> 4) We checked the wrong feature flags when taking down
>    an interface with IPsec offload enabled.
>    Fix from Ilan Tayari.
> 
> 5) Copy the anti replay sequence numbers when doing a state
>    migration, otherwise we get out of sync with the sequence
>    numbers. Fix from Antony Antony.
> 
> Please pull or let me know if there are problems.

Pulled, thank you.
