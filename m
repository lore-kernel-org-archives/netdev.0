From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: sr: fix IPv6 initialization failure
 without lwtunnels
Date: Sun, 13 Nov 2016 00:20:55 -0500 (EST)
Message-ID: <20161113.002055.1386089188095640295.davem@davemloft.net>
References: <CAKD1Yr0fDFdDv9+S3i_rH6W6btEuvs9s-h33_N67iM4qrtDezQ@mail.gmail.com>
        <1478780813-20005-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33026 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750815AbcKMFVD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 00:21:03 -0500
In-Reply-To: <1478780813-20005-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Thu, 10 Nov 2016 13:26:53 +0100

> v2: fix conditional compilation for seg6_iptunnel.o in Makefile
> 
> This patch compiles SR lwtunnels support only if CONFIG_LWTUNNEL=y.
> 
> If IPv6 is enabled and CONFIG_LWTUNNEL=n, then seg6_iptunnel_init()
> fails with EOPNOTSUPP which in turn makes seg6_init() fail, blocking
> the IPv6 initialization, with the following messages:
> 
> NET: Registered protocol family 10
> IPv6: Attempt to unregister permanent protocol 6
> IPv6: Attempt to unregister permanent protocol 136
> IPv6: Attempt to unregister permanent protocol 17
> NET: Unregistered protocol family 10
> 
> Fix commit 6c8702c60b88 ("ipv6: sr: add support for SRH encapsulation and injection with lwtunnels")
> 
> Tested with various combinations of CONFIG_IPV6 and CONFIG_LWTUNNEL.
> 
> Reported-by: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Applied, thanks David.
