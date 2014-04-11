From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv6: Fix oif in TCP SYN+ACK route lookup.
Date: Fri, 11 Apr 2014 16:44:27 -0400 (EDT)
Message-ID: <20140411.164427.1090382302661075075.davem@davemloft.net>
References: <1397189952-31438-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	wangyufen@huawei.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067AbaDKUo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 16:44:29 -0400
In-Reply-To: <1397189952-31438-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Fri, 11 Apr 2014 13:19:12 +0900

> net-next commit 9c76a11, ipv6: tcp_ipv6 policy route issue, had
> a boolean logic error that caused incorrect behaviour for TCP
> SYN+ACK when oif-based rules are in use. Specifically:
> 
> 1. If a SYN comes in from a global address, and sk_bound_dev_if
>    is not set, the routing lookup has oif set to the interface
>    the SYN came in on. Instead, it should have oif unset,
>    because for global addresses, the incoming interface doesn't
>    necessarily have any bearing on the interface the SYN+ACK is
>    sent out on.
> 2. If a SYN comes in from a link-local address, and
>    sk_bound_dev_if is set, the routing lookup has oif set to the
>    interface the SYN came in on. Instead, it should have oif set
>    to sk_bound_dev_if, because that's what the application
>    requested.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied, thank you.
