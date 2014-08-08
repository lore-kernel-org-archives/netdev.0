From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: fix VF info size
Date: Fri, 08 Aug 2014 10:34:34 -0700 (PDT)
Message-ID: <20140808.103434.1754779724613937273.davem@davemloft.net>
References: <8491096ac8f0e7cc7745411c0af87fb5a146d44e.1407509058.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ronye@mellanox.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbaHHRef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 13:34:35 -0400
In-Reply-To: <8491096ac8f0e7cc7745411c0af87fb5a146d44e.1407509058.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri,  8 Aug 2014 16:44:32 +0200

> Commit 1d8faf48c74b8 ("net/core: Add VF link state control") added new
> attribute to IFLA_VF_INFO group in rtnl_fill_ifinfo but did not adjust size
> of the allocated memory in if_nlmsg_size/rtnl_vfinfo_size. As the result, we
> may trigger warnings in rtnl_getlink and similar functions when many VF
> links are enabled, as the information does not fit into the allocated skb.
> 
> Fixes: 1d8faf48c74b8 ("net/core: Add VF link state control")
> Reported-by: Yulong Pei <ypei@redhat.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied and queued up for -stable, thanks!
