From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwtunnel: subtract tunnel headroom from mtu
 on output redirect
Date: Wed, 16 Nov 2016 17:01:29 -0500 (EST)
Message-ID: <20161116.170129.532116942757193881.davem@davemloft.net>
References: <1479287146-25766-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754094AbcKPWBg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 17:01:36 -0500
In-Reply-To: <1479287146-25766-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Wed, 16 Nov 2016 10:05:46 +0100

> This patch changes the lwtunnel_headroom() function which is called
> in ipv4_mtu() and ip6_mtu(), to also return the correct headroom
> value when the lwtunnel state is OUTPUT_REDIRECT.
> 
> This patch enables e.g. SR-IPv6 encapsulations to work without
> manually setting the route mtu.
> 
> Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Applied, thanks David.
