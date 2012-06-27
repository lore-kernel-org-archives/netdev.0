From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/18] netfilter: nfnetlink_log: Move away from
 NLMSG_PUT().
Date: Wed, 27 Jun 2012 15:06:40 -0700 (PDT)
Message-ID: <20120627.150640.281556392908197937.davem@davemloft.net>
References: <20120626.220223.1090653207727010874.davem@davemloft.net>
	<1340815773.2591.9.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403Ab2F0WGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 18:06:40 -0400
In-Reply-To: <1340815773.2591.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 Jun 2012 17:49:33 +0100

> It looks like this also leaks the skb on failure.  At least,
> __nfulnl_flush(inst) is expected to dipose of inst->skb.

I did not change the behavior of this function, if someone wants
to fix this bug that's great, but I'm certainly not obligated to
do so.
