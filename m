From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Thu, 13 Jul 2006 15:01:45 -0700 (PDT)
Message-ID: <20060713.150145.35663460.davem@davemloft.net>
References: <20060713203615.GA26954@lst.de>
	<20060713142440.0e487717@dxpl.pdx.osdl.net>
	<20060713212919.GA28412@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24273
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030373AbWGMWBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 18:01:44 -0400
To: hch@lst.de
In-Reply-To: <20060713212919.GA28412@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Thu, 13 Jul 2006 23:29:19 +0200

> > What's the new name? For sanity, don't reuse the name dev_alloc_skb.
> 
> dev_alloc_skb.  It's the by far sanest name for it, while the old
> usage without dev argument was misleading.

As much as I would like to make a clean break, you just can't
do this Christoph.

There is so much out of tree code that we will unfairly break
by doing this.

Add a new name, schedule dev_alloc_skb for a 6 month removal,
and convert as much of the in-tree uses as you like.  Mark
dev_alloc_skb deprecated while you're at it.

This is consistent with how we handle any other widely used
interface in the kernel.
