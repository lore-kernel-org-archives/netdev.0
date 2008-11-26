From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Use a percpu_counter for orphan_count
Date: Tue, 25 Nov 2008 21:17:29 -0800 (PST)
Message-ID: <20081125.211729.233162547.davem@davemloft.net>
References: <492C85AA.9080205@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56673
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753077AbYKZFR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 00:17:29 -0500
In-Reply-To: <492C85AA.9080205@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 26 Nov 2008 00:09:30 +0100

> [PATCH] net: Use a percpu_counter for orphan_count
> 
> Instead of using one atomic_t per protocol, use a percpu_counter
> for "orphan_count", to reduce cache line contention on
> heavy duty network servers. 
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Also applied, thanks Eric.
