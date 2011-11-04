From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: validate NLA_MSECS length
Date: Fri, 04 Nov 2011 17:48:33 -0400 (EDT)
Message-ID: <20111104.174833.2136311568196288477.davem@davemloft.net>
References: <1320314852.3950.36.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926Ab1KDVuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 17:50:52 -0400
In-Reply-To: <1320314852.3950.36.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 03 Nov 2011 11:07:32 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> L2TP for example uses NLA_MSECS like this:
> policy:
>         [L2TP_ATTR_RECV_TIMEOUT]        = { .type = NLA_MSECS, },
> code:
>         if (info->attrs[L2TP_ATTR_RECV_TIMEOUT])
>                 cfg.reorder_timeout = nla_get_msecs(info->attrs[L2TP_ATTR_RECV_TIMEOUT]);
> 
> As nla_get_msecs() is essentially nla_get_u64() plus the
> conversion to a HZ-based value, this will not properly
> reject attributes from userspace that aren't long enough
> and might overrun the message.
> 
> Add NLA_MSECS to the attribute minlen array to check the
> size properly.
> 
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: stable@vger.kernel.org
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks!
