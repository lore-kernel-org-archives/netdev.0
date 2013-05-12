From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] xfrm6: release dev before returning error
Date: Sat, 11 May 2013 17:41:49 -0700 (PDT)
Message-ID: <20130511.174149.1568987936575630848.davem@davemloft.net>
References: <1368175200-26877-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au,
	steffen.klassert@secunet.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748Ab3ELAlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 20:41:49 -0400
In-Reply-To: <1368175200-26877-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 10 May 2013 16:40:00 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> We forget to call dev_put() on error path in xfrm6_fill_dst(),
> its caller doesn't handle this.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied and queued up for -stable.
