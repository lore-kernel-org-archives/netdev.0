From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] {ipv4,xfrm}: Introduce xfrm_tunnel_notifier
 for xfrm tunnel mode callback
Date: Mon, 26 Aug 2013 16:21:35 -0400 (EDT)
Message-ID: <20130826.162135.1765443562851401512.davem@davemloft.net>
References: <1377240424-11758-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, saurabh.mohan@vyatta.com,
	herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043Ab3HZUVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 16:21:37 -0400
In-Reply-To: <1377240424-11758-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Fri, 23 Aug 2013 14:47:04 +0800

> Some thoughts on IPv4 VTI implementation:
> 
> The connection between VTI receiving part and xfrm tunnel mode input process
> is hardly a "xfrm_tunnel", xfrm_tunnel is used in places where, e.g ipip/sit
> and xfrm4_tunnel, acts like a true "tunnel" device.
> 
> In addition, IMHO, VTI doesn't need vti_err to do something meaningful, as all
> VTI needs is just a notifier to be called whenever xfrm_input ingress a packet
> to update statistics.
> 
> So this patch introduce xfrm_tunnel_notifier and meanwhile wipe out vti_erri
> code.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

I don't understand why VTI doesn't need to propagate a PMTU update via
ipv4_update_pmtu().  Why is it different from a real xfrm_tunnel?

Your changelog has to explain this better and in more detail.

Thanks.
