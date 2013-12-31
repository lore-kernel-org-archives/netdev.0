From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: unneccessary to get address prefix in
 addrconf_get_prefix_route
Date: Tue, 31 Dec 2013 13:38:03 -0500 (EST)
Message-ID: <20131231.133803.2135086760819574850.davem@davemloft.net>
References: <1387762358-10607-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832Ab3LaSiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 13:38:05 -0500
In-Reply-To: <1387762358-10607-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon, 23 Dec 2013 09:32:38 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Since addrconf_get_prefix_route inputs the address prefix to fib6_locate,
> which does not uses the data which is out of the prefix_len length,
> so do not need to use ipv6_addr_prefix to get address prefix.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
