From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] rtnetlink: pass link_net to the newlink
 handler
Date: Thu, 29 Jan 2015 14:23:46 -0800 (PST)
Message-ID: <20150129.142346.2067967163788035274.davem@davemloft.net>
References: <54C61ED1.5040501@6wind.com>
	<1422353588-4830-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbbA2WXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 17:23:46 -0500
In-Reply-To: <1422353588-4830-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 27 Jan 2015 11:13:08 +0100

> When IFLA_LINK_NETNSID is used, the netdevice should be built in this link netns
> and moved at the end to another netns (pointed by the socket netns or
> IFLA_NET_NS_[PID|FD]).
> 
> Existing user of the newlink handler will use the netns argument (src_net) to
> find a link netdevice or to check some other information into the link netns.
> For example, to find a netdevice, two information are required: an ifindex
> (usually from IFLA_LINK) and a netns (this link netns).
> 
> Note: when using IFLA_LINK_NETNSID and IFLA_NET_NS_[PID|FD], a user may create a
> netdevice that stands in netnsX and with its link part in netnsY, by sending a
> rtnl message from netnsZ.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
