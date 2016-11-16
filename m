From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] ipv6: sr: add option to control lwtunnel
 support
Date: Wed, 16 Nov 2016 11:32:35 -0500 (EST)
Message-ID: <20161116.113235.1086857909675049587.davem@davemloft.net>
References: <1479222844-20301-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com,
        roopa@cumulusnetworks.com
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43830 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753202AbcKPQcg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 11:32:36 -0500
In-Reply-To: <1479222844-20301-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Tue, 15 Nov 2016 16:14:04 +0100

> This patch adds a new option CONFIG_IPV6_SEG6_LWTUNNEL to enable/disable
> support of encapsulation with the lightweight tunnels. When this option
> is enabled, CONFIG_LWTUNNEL is automatically selected.
> 
> Fix commit 6c8702c60b88 ("ipv6: sr: add support for SRH encapsulation and injection with lwtunnels")
> 
> Without a proper option to control lwtunnel support for SR-IPv6, if
> CONFIG_LWTUNNEL=n then the IPv6 initialization fails as a consequence
> of seg6_iptunnel_init() failure with EOPNOTSUPP:
> 
> NET: Registered protocol family 10
> IPv6: Attempt to unregister permanent protocol 6
> IPv6: Attempt to unregister permanent protocol 136
> IPv6: Attempt to unregister permanent protocol 17
> NET: Unregistered protocol family 10
> 
> Tested (compiling, booting, and loading ipv6 module when relevant)
> with possible combinations of CONFIG_IPV6={y,m,n},
> CONFIG_IPV6_SEG6_LWTUNNEL={y,n} and CONFIG_LWTUNNEL={y,n}.
> 
> Reported-by: Lorenzo Colitti <lorenzo@google.com>
> Suggested-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Applied.
