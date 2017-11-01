From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2017-11-01
Date: Wed, 01 Nov 2017 19:32:43 +0900 (KST)
Message-ID: <20171101.193243.1546128799940823540.davem@davemloft.net>
References: <1509530703-12707-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51034 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751344AbdKAKcr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 06:32:47 -0400
In-Reply-To: <1509530703-12707-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 1 Nov 2017 11:05:00 +0100

> 1) Fix a memleak when a packet matches a policy
>    without a matching state.
> 
> 2) Reset the socket cached dst_entry when inserting
>    a socket policy, otherwise the policy might be
>    ignored. From Jonathan Basseri.
> 
> 3) Fix GSO for a IPsec, GRE tunnel combination.
>    We reset the encapsulation field at the skb
>    too erly, as a result GRE does not segment
>    GSO packets. Fix this by resetting the the
>    encapsulation field right before the
>    transformation where the inner headers get
>    invalid.
> 
> Please pull or let me know if there are problems.

Pulled, thanks.
