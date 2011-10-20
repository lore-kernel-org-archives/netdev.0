From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio_net: fix truesize underestimation
Date: Thu, 20 Oct 2011 05:23:54 -0400 (EDT)
Message-ID: <20111020.052354.2288803249088439664.davem@davemloft.net>
References: <1319102086.3781.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, krkumar2@in.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349Ab1JTJ1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 05:27:05 -0400
In-Reply-To: <1319102086.3781.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 11:14:46 +0200

> We must account in skb->truesize, the size of the fragments, not the
> used part of them.
> 
> Doing this work is important to avoid unexpected OOM situations.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
