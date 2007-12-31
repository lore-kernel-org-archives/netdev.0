From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Fix double free on skb on async output
Date: Sun, 30 Dec 2007 21:10:54 -0800 (PST)
Message-ID: <20071230.211054.162970990.davem@davemloft.net>
References: <20071230123603.GA24629@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48903
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750974AbXLaFKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 00:10:55 -0500
In-Reply-To: <20071230123603.GA24629@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 30 Dec 2007 23:36:04 +1100

> [IPSEC]: Fix double free on skb on async output
> 
> When the output transform returns EINPROGRESS due to async operation we'll
> free the skb the straight away as if it were an error.  This patch fixes
> that so that the skb is freed when the async operation completes.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
