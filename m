From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: ipv6: Fix oif in TCP SYN+ACK route lookup.
Date: Fri, 11 Apr 2014 15:19:41 +0200
Message-ID: <20140411131941.GN27255@order.stressinduktion.org>
References: <1397189952-31438-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, wangyufen@huawei.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37544 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247AbaDKNTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 09:19:43 -0400
Content-Disposition: inline
In-Reply-To: <1397189952-31438-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2014 at 01:19:12PM +0900, Lorenzo Colitti wrote:
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

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
