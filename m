From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : convert IP route cache garbage colleciton from
 softirq processing to a workqueue
Date: Wed, 12 Sep 2007 05:30:36 -0700 (PDT)
Message-ID: <20070912.053036.08339591.davem@davemloft.net>
References: <20070912120845.1b2d77dc.dada1@cosmosbay.com>
	<20070912.041200.15253216.davem@davemloft.net>
	<20070912141656.394e1f28.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	hch@infradead.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:49929
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758927AbXILMbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:31:20 -0400
In-Reply-To: <20070912141656.394e1f28.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 12 Sep 2007 14:16:56 +0200

> OK, let's try a normal prefetch(), I'll change it later when/if a 
> new generic macro is added. I added the missing 'static' and a comment
> about the "struct {} dst_garbage". I also corrected spelling error on
> patch title (collection)

I sorted out the conflicts with the network namespace stuff
I just checked in and added your patch to net-2.6.24

Thanks!
