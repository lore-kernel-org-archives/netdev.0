From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET is
 enabled
Date: Tue, 03 Nov 2015 13:20:15 -0500 (EST)
Message-ID: <20151103.132015.944876907781932861.davem@davemloft.net>
References: <20151103.103319.1465681990237533576.davem@davemloft.net>
	<1446568644.23275.65.camel@edumazet-glaptop2.roam.corp.google.com>
	<BN1PR0301MB07704B4966A54DC679505962CA2B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, kys@microsoft.com, edumazet@google.com,
	netdev@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbbKCSUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 13:20:21 -0500
In-Reply-To: <BN1PR0301MB07704B4966A54DC679505962CA2B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue, 3 Nov 2015 17:34:47 +0000

> But we still keep this busy return in our code, just for "weird corner cases".

The queue_stopped condition must be precise.

If you cannot enqueue a maximally segmented SKB, you must stop the queue.
