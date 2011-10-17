From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove a rcu_read_lock in
 ndisc_constructor
Date: Mon, 17 Oct 2011 19:28:22 -0400 (EDT)
Message-ID: <20111017.192822.493016481473100926.davem@davemloft.net>
References: <1317707015-2432-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rongqing.li@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753648Ab1JQX21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 19:28:27 -0400
In-Reply-To: <1317707015-2432-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <rongqing.li@windriver.com>
Date: Tue, 4 Oct 2011 13:43:35 +0800

> From: Roy.Li <rongqing.li@windriver.com>
> 
> in6_dev_get(dev) takes a reference on struct inet6_dev, we dont need
> rcu locking in ndisc_constructor()
> 
> Signed-off-by: Roy.Li <rongqing.li@windriver.com>

Applied, thanks.
