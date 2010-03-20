From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: check rt_genid in dst_check
Date: Fri, 19 Mar 2010 21:08:25 -0700 (PDT)
Message-ID: <20100319.210825.59665638.davem@davemloft.net>
References: <1268978083-32070-1-git-send-email-timo.teras@iki.fi>
	<20100319085600.GA23705@gondor.apana.org.au>
	<20100319090022.GA23751@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44632
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751056Ab0CTEIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 00:08:02 -0400
In-Reply-To: <20100319090022.GA23751@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 19 Mar 2010 17:00:22 +0800

> On Fri, Mar 19, 2010 at 04:56:00PM +0800, Herbert Xu wrote:
>> 
>> I'll send a patch to remove the same check on the IPv6 path.
> 
> ipv6: Remove redundant dst NULL check in ip6_dst_check
> 
> As the only path leading to ip6_dst_check makes an indirect call
> through dst->ops, dst cannot be NULL in ip6_dst_check.
> 
> This patch removes this check in case it misleads people who
> come across this code.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
