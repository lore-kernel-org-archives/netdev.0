From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] net: correct check in dev_addr_del()
Date: Wed, 14 Nov 2012 21:52:54 -0500 (EST)
Message-ID: <20121114.215254.973344009331632746.davem@davemloft.net>
References: <1352897464-832-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	shemminger@vyatta.com, john.r.fastabend@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933167Ab2KOCwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 21:52:55 -0500
In-Reply-To: <1352897464-832-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 14 Nov 2012 13:51:04 +0100

> Check (ha->addr == dev->dev_addr) is always true because dev_addr_init()
> sets this. Correct the check to behave properly on addr removal.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

I'm pretty sure this is very intentional.

It's trying to prevent deletion of the implicit dev->dev_addr
entry.  But it will allow decementing the reference count to
1, but no further.

I'm not applying this.
