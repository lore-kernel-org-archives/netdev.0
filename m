From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb3: remove __GFP_NOFAIL usage
Date: Thu, 11 Jun 2009 02:51:43 -0700 (PDT)
Message-ID: <20090611.025143.72222412.davem@davemloft.net>
References: <20090610092521.8871.39255.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, akpm@odsl.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35560
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760643AbZFKJvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:51:41 -0400
In-Reply-To: <20090610092521.8871.39255.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 10 Jun 2009 02:25:21 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> Pre-allocate a skb at init time to be used for control messages to the HW
> if skb allocation fails.
> 
> Tolerate failures to send messages initializing some memories at the cost of
> parity error detection for these memories.
> Retry sending connection id release messages if both alloc_skb(GFP_ATOMIC)
> and alloc_skb(GFP_KERNEL) fail.
> Do not bring the interface up if messages binding queue set to port fail to
> be sent.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
