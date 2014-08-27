From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 13:48:06 -0700 (PDT)
Message-ID: <20140827.134806.592959426691842728.davem@davemloft.net>
References: <1409142672.26515.24.camel@localhost>
	<1409145838.3173.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140827155651.04fe49d0@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, therbert@google.com, jhs@mojatatu.com,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965084AbaH0UsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 16:48:07 -0400
In-Reply-To: <20140827155651.04fe49d0@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 27 Aug 2014 15:56:51 +0200

> I do worry a bit, if writing skb->xmit_more in a more cache cold
> scenarios could hurt us (as that cacheline seems to be read mostly),
> but this is not a problem right now because it will always be cache
> hot, as we always clear the entire SKB in alloc.

And as I mentioned to Eric, xmit_more sits right next to the queue
number which is also dirtied in the TX path.
