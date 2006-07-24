From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] remove CONFIG_HAVE_ARCH_DEV_ALLOC_SKB
Date: Mon, 24 Jul 2006 15:30:44 -0700 (PDT)
Message-ID: <20060724.153044.10246226.davem@davemloft.net>
References: <20060707091008.GB2543@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36519
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932300AbWGXWae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 18:30:34 -0400
To: hch@lst.de
In-Reply-To: <20060707091008.GB2543@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Fri, 7 Jul 2006 11:10:08 +0200

> skbuff.h has an #ifndef CONFIG_HAVE_ARCH_DEV_ALLOC_SKB to allow
> architectures to reimplement __dev_alloc_skb.  It's not set on any
> architecture and now that we have an architecture-overrideable
> NET_SKB_PAD there is not point at all to have one either.
> 
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Applied, thanks Christoph.
