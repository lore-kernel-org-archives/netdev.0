From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: simplify detection of first operational
 link-local address on interface
Date: Fri, 17 Jan 2014 18:10:33 -0800 (PST)
Message-ID: <20140117.181033.1283452444632089563.davem@davemloft.net>
References: <20140116135323.GA7961@minipsycho.orion>
	<20140116191304.GC17529@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, fbl@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbaARCKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 21:10:34 -0500
In-Reply-To: <20140116191304.GC17529@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 16 Jan 2014 20:13:04 +0100

> In commit 1ec047eb4751e3 ("ipv6: introduce per-interface counter for
> dad-completed ipv6 addresses") I build the detection of the first
> operational link-local address much to complex. Additionally this code
> now has a race condition.
> 
> Replace it with a much simpler variant, which just scans the address
> list when duplicate address detection completes, to check if this is
> the first valid link local address and send RS and MLD reports then.
> 
> Fixes: 1ec047eb4751e3 ("ipv6: introduce per-interface counter for dad-completed ipv6 addresses")
> Reported-by: Jiri Pirko <jiri@resnulli.us>
> Cc: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
