From: David Miller <davem@davemloft.net>
Subject: Re: [SKBUFF]: Fix up csum_start when head room changes
Date: Sun, 16 Sep 2007 16:33:19 -0700 (PDT)
Message-ID: <20070916.163319.105429760.davem@davemloft.net>
References: <20070901011333.GA5223@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55959
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753664AbXIPXdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:33:20 -0400
In-Reply-To: <20070901011333.GA5223@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 1 Sep 2007 09:13:33 +0800

> Hi Dave:
> 
> [SKBUFF]: Fix up csum_start when head room changes
> 
> Thanks for noticing the bug where csum_start is not updated
> when the head room changes.
> 
> This patch fixes that.  It also moves the csum/ip_summed
> copying into copy_skb_header so that skb_copy_expand gets
> it too.  I've checked its callers and no one should be upset
> by this.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Herbert, thanks for following up on this.

Although this is technically a "bug fix" we don't have anyone
explicitly triggering this and I don't feel comfortable pushing this
into net-2.6 without a reported failure case right now.

So I applied it to net-2.6.24 for now.

If you disagree, plead your case :-)

