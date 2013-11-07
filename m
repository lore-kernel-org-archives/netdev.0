From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Thu, 07 Nov 2013 17:06:51 -0500 (EST)
Message-ID: <20131107.170651.1819930710384730745.davem@davemloft.net>
References: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
	<20131107.161755.355597965034457889.davem@davemloft.net>
	<20131107213111.GA6885@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, eric.dumazet@gmail.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab3KGWGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 17:06:55 -0500
In-Reply-To: <20131107213111.GA6885@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 8 Nov 2013 05:31:11 +0800

> Sorry David, I just realised that this patch doesn't address
> this problem fully.  While we can stop the generation of these
> packets in our own stack, if they're coming from the virt host
> or another guest, there is nothing we can do to stop them.
> 
> So given virtio_net is now generating such packets, our choices
> are either to linearise them or deal with them properly in skb_segment.

Ok.

Aside from the segmentation issues, Eric's patch was a nice cleanup
which also made it such that we'd be able to get features back when
the blocking condition gets removed.

Given all of this, would you like me to revert his change for now?
