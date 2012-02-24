From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] mlx4_en: TX ring size default to 1024
Date: Fri, 24 Feb 2012 15:14:15 -0500 (EST)
Message-ID: <20120224.151415.831305774793653355.davem@davemloft.net>
References: <4F46404D.10509@mellanox.co.il>
	<20120223.144541.1354349294973443529.davem@davemloft.net>
	<953B660C027164448AE903364AC447D2618B8768@MTLDAG02.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757840Ab2BXUOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 15:14:21 -0500
In-Reply-To: <953B660C027164448AE903364AC447D2618B8768@MTLDAG02.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Date: Fri, 24 Feb 2012 19:35:45 +0000

> On the other hand, when having smaller queue with 1000 in-flight
> packets would mean queue would be stopped, how is it better?

It's a thousand times better.

Because if a high priority packet gets queued up it won't have to wait
for 1024 packets to hit the wire before it can go out.

You need to support byte queue limits before you jack things up so high
like this, otherwise high priority packets are absolutely pointless
and unusable.
