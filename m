From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] net: Use device model to get driver name in
 skb_gso_segment()
Date: Tue, 17 Jan 2012 10:32:28 -0500 (EST)
Message-ID: <20120117.103228.149366421965709494.davem@davemloft.net>
References: <1326753539.3065.31.camel@bwh-desktop>
	<20120116224138.GA12523@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547Ab2AQPcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 10:32:36 -0500
In-Reply-To: <20120116224138.GA12523@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Tue, 17 Jan 2012 09:41:38 +1100

> On Mon, Jan 16, 2012 at 10:38:59PM +0000, Ben Hutchings wrote:
>> ethtool operations generally require the caller to hold RTNL and are
>> not safe to call in atomic context.  The device model provides this
>> information for most devices; we'll only lose it for some old ISA
>> drivers.
>> 
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
