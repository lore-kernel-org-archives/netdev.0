From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: fix wrong subscription bitmask to group
 mapping in binding callbacks
Date: Thu, 08 Jan 2015 20:04:29 -0800 (PST)
Message-ID: <20150108.200429.1274496391828010187.davem@davemloft.net>
References: <1420633915-25475-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50665 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbbAID6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 22:58:46 -0500
In-Reply-To: <1420633915-25475-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed,  7 Jan 2015 13:31:55 +0100

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
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

This gets rejects when I try to apply it to 'net', please
respin.

Thanks.
