From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] switchdev: pass pointer to fib_info instead of copy
Date: Tue, 17 May 2016 14:00:36 -0400 (EDT)
Message-ID: <20160517.140036.1802823189592173373.davem@davemloft.net>
References: <1463504288-2226-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49102 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbcEQSAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 14:00:41 -0400
In-Reply-To: <1463504288-2226-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 17 May 2016 18:58:08 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> The problem is that fib_info->nh is [0] so the struct fib_info
> allocation size depends on number of nexthops. If we just copy fib_info,
> we do not copy the nexthops info and driver accesses memory which is not
> ours.

Oops.

> Given the fact that fib4 does not defer operations and therefore it does
> not need copy, just pass the pointer down to drivers as it was done
> before.
> 
> Fixes: 850d0cbc91 ("switchdev: remove pointers from switchdev objects")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied and queued up for -stable, thanks Jiri.
