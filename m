From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] net: clean up skb headers code
Date: Fri, 31 May 2013 17:03:22 -0700 (PDT)
Message-ID: <20130531.170322.303782960714462064.davem@davemloft.net>
References: <1369811765-22282-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715Ab3FAADX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:03:23 -0400
In-Reply-To: <1369811765-22282-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 29 May 2013 15:16:05 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
> fields of struct skbuff) converts skb->*_header to u16,
> some #if NET_SKBUFF_DATA_USES_OFFSET are now useless,
> and to be safe, we could just use "X = (typeof(X)) ~0U;"
> as suggested by David.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Simon Horman <horms@verge.net.au>
> Signed-off-by: Cong Wang <amwang@redhat.com>

After much internal deliberation, I still like this approach the
best because it prevents mistakes in the future.

Applied, thanks.
