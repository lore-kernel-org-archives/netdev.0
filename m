From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Use consistent NF_DROP returns in nf_pre_routing
Date: Fri, 10 Dec 2010 16:05:23 -0800 (PST)
Message-ID: <20101210.160523.186298802.davem@davemloft.net>
References: <20101210033811.GA4803@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58384
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756822Ab0LKAEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:04:55 -0500
In-Reply-To: <20101210033811.GA4803@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 10 Dec 2010 11:38:11 +0800

> Hi:
> 
> bridge: Use consistent NF_DROP returns in nf_pre_routing
> 
> The nf_pre_routing functions in bridging have collected two
> distinct ways of returning NF_DROP over the years, inline and
> via goto.  There is no reason for preferring either one.
> 
> So this patch arbitrarily picks the inline variant and converts
> the all the gotos.
> 
> Also removes a redundant comment.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
