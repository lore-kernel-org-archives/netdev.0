From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter
 irqbalance hints
Date: Tue, 24 Nov 2009 10:54:42 -0800 (PST)
Message-ID: <20091124.105442.06273019.davem@davemloft.net>
References: <20091124.093956.247147202.davem@davemloft.net>
	<1259085412.2631.48.camel@ppwaskie-mobl2>
	<4B0C2547.8030408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, peterz@infradead.org,
	arjan@linux.intel.com, yong.zhang0@gmail.com,
	linux-kernel@vger.kernel.org, arjan@linux.jf.intel.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53436
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933857AbZKXSyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 13:54:24 -0500
In-Reply-To: <4B0C2547.8030408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Nov 2009 19:26:15 +0100

> It seems complex to me, maybe optimal thing would be to use a NUMA policy to
> spread vmalloc() allocations to all nodes to get a good bandwidth...

vmalloc() and sk_buff's don't currently mix and I really don't see us
every allowing them to :-)
