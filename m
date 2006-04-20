From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TCP]: Account skb overhead in tcp_fragment
Date: Wed, 19 Apr 2006 21:31:15 -0700 (PDT)
Message-ID: <20060419.213115.74232309.davem@davemloft.net>
References: <20060420010111.GA20576@gondor.apana.org.au>
	<20060420032602.GA21406@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23715
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751256AbWDTEbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 00:31:37 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060420032602.GA21406@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 20 Apr 2006 13:26:02 +1000

> On Thu, Apr 20, 2006 at 11:01:11AM +1000, herbert wrote:
> > Hi Dave:
> > 
> > Since sk_stream_alloc_pskb takes an extra argument that accounts for
> > paged data all we need to do to account sk_buff overhead correctly
> > is to use that instead of sk_stream_alloc_skb.
> 
> Here is a better version that does not double-count the paged bits
> that get moved across.
>  
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good, I'll apply this.
