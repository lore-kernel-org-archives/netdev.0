From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] hfsc: reduce hfsc_sched to 14 cachelines
Date: Fri, 08 Jul 2016 23:09:01 -0400 (EDT)
Message-ID: <20160708.230901.2033851388253631522.davem@davemloft.net>
References: <1467642140-19156-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soltys@ziu.info
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932844AbcGIDJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 23:09:06 -0400
In-Reply-To: <1467642140-19156-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon,  4 Jul 2016 16:22:20 +0200

> hfsc_sched is huge (size: 920, cachelines: 15), but we can get it to 14
> cachelines by placing level after filter_cnt (covering 4 byte hole) and
> reducing period/nactive/flags to u32 (period is just a counter,
> incremented when class becomes active -- 2**32 is plenty for this
> purpose, also, long is only 32bit wide on 32bit platforms anyway).
> 
> cl_vtperiod is exported to userspace via tc_hfsc_stats, but its period
> member is already u32, so no precision is lost there either.
> 
> Cc: Michal Soltys <soltys@ziu.info>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
