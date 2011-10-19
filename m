From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix guest memory leak and panic
Date: Wed, 19 Oct 2011 19:42:05 -0400 (EDT)
Message-ID: <20111019.194205.2298875957485608359.davem@davemloft.net>
References: <1318944002.2657.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1319014511.3385.72.camel@zakaz.uk.xensource.com>
	<1319015259.3103.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian.Campbell@citrix.com, krkumar2@in.ibm.com,
	rusty@rustcorp.com.au, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319015259.3103.3.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Oct 2011 11:07:39 +0200

>> From 369022220db31efb9c261cbabcb890a4d216a176 Mon Sep 17 00:00:00 2001
>> From: Ian Campbell <ian.campbell@citrix.com>
>> Date: Tue, 18 Oct 2011 09:59:37 +0100
>> Subject: [PATCH] net: do not take an additional reference in skb_frag_set_page
>> 
>> I audited all of the callers in the tree and only one of them (pktgen) expects
>> it to do so. Taking this reference is pretty obviously confusing and error
>> prone.
>> 
>> In particular I looked at the following commits which switched callers of
>> (__)skb_frag_set_page to the skb paged fragment api:
 ...
>> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
 ...
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
