From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove redundant code in
 dev_hard_start_xmit()
Date: Thu, 25 Apr 2013 01:39:25 -0400 (EDT)
Message-ID: <20130425.013925.570609780164675360.davem@davemloft.net>
References: <1366677094.16391.97.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, krkumar2@in.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab3DYFj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:39:27 -0400
In-Reply-To: <1366677094.16391.97.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Apr 2013 17:31:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> This reverts commit 068a2de57ddf4f4 (net: release dst entry while
> cache-hot for GSO case too)
> 
> Before GSO packet segmentation, we already take care of skb->dst if it
> can be released.
> 
> There is no point adding extra test for every segment in the gso loop.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
