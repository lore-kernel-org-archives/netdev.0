From: David Miller <davem@davemloft.net>
Subject: Re: [kbuild] [net-next:master 5/11]
 drivers/net/macvlan.c:262:23-26: ERROR: skb is NULL but dereferenced.
Date: Wed, 23 Apr 2014 14:56:08 -0400 (EDT)
Message-ID: <20140423.145608.1518295148640909261.davem@davemloft.net>
References: <20140422084934.GU4963@mwanda>
	<20140422091533.GA22971@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, kbuild@01.org, julia.lawall@lip6.fr,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbaDWS4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 14:56:10 -0400
In-Reply-To: <20140422091533.GA22971@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 22 Apr 2014 17:15:34 +0800

> macvlan: Fix leak and NULL dereference on error path
> 
> The recent patch that moved broadcasts to process context added
> a couple of bugs on the error path where we may dereference NULL
> or leak an skb.  This patch fixes them.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
