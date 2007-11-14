From: David Miller <davem@davemloft.net>
Subject: Re: [NET] random : secure_tcp_sequence_number should not assume
 CONFIG_KTIME_SCALAR
Date: Tue, 13 Nov 2007 21:13:16 -0800 (PST)
Message-ID: <20071113.211316.25189246.davem@davemloft.net>
References: <47398ADD.2030509@cosmosbay.com>
	<20071113.035019.268404275.davem@davemloft.net>
	<4739A97F.60206@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, stable@kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48484
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763185AbXKNFNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:13:16 -0500
In-Reply-To: <4739A97F.60206@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 13 Nov 2007 14:41:19 +0100

> I discovered one other incorrect use of .tv64 (coming from me, I must 
> confess)
> 
> I guess this patch is  needed for 2.6.24 and stable (2.6.22 & 2.6.23)
 ...
> [NET] random : secure_tcp_sequence_number should not assume 
> CONFIG_KTIME_SCALAR

Applied thanks Eric, I'll queue it up for -stable too.

Perhaps ktime_t->tv64 should be renamed to "->__tv64" or
similar to prevent future mistakes like this.  Only
the ktime implementation should be touching that thing.
