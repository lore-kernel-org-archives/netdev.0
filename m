From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 14:23:24 -0400 (EDT)
Message-ID: <20160419.142324.1774057494079734967.davem@davemloft.net>
References: <20160418.214851.122286645854721047.davem@davemloft.net>
	<20160418.235207.395468709808133833.davem@davemloft.net>
	<1461060543.2766.20.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, roopa@cumulusnetworks.com,
	netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, egrumbach@gmail.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbcDSSXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 14:23:31 -0400
In-Reply-To: <1461060543.2766.20.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 19 Apr 2016 12:09:03 +0200

> At netconf, we talked about how awkward it can be that one doesn't know
> if an attribute was accepted by the kernel or simply ignored because
> it's not supported (older kernel version).
> 
> I considered (and Emmanuel has started to cook up a patch for it)
> adding a flag here meaning "reject if not parsed" (or so).
> 
> Now, I realize that with all the existing netlink commands one can't
> actually rely on that (since it requires some infrastructure), but new
> commands in existing families and also entirely new generic netlink
> families would allow let userspace rely on such a thing.

I like this nlattr flag idea, it's opt-in and any tool can be updated
to use the new facility.

I'd be willing the backport the nlattr flag bit change to all stable
releases as well.
