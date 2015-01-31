From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: fix wrong subscription bitmask to group
 mapping in
Date: Fri, 30 Jan 2015 17:44:57 -0800 (PST)
Message-ID: <20150130.174457.1399299755338734165.davem@davemloft.net>
References: <1422525113-5698-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, colona@arista.com, andre@tomt.net
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320AbbAaBo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 20:44:59 -0500
In-Reply-To: <1422525113-5698-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 29 Jan 2015 10:51:53 +0100

> The subscription bitmask passed via struct sockaddr_nl is converted to
> the group number when calling the netlink_bind() and netlink_unbind()
> callbacks.
> 
> The conversion is however incorrect since bitmask (1 << 0) needs to be
> mapped to group number 1. Note that you cannot specify the group number 0
> (usually known as _NONE) from setsockopt() using NETLINK_ADD_MEMBERSHIP
> since this is rejected through -EINVAL.
> 
> This problem became noticeable since 97840cb ("netfilter: nfnetlink:
> fix insufficient validation in nfnetlink_bind") when binding to bitmask
> (1 << 0) in ctnetlink.
> 
> Reported-by: Andre Tomt <andre@tomt.net>
> Reported-by: Ivan Delalande <colona@arista.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied, thanks Pablo.
