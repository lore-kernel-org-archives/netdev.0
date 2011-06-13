From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] l2tp: fix l2tp_ip_sendmsg() route handling
Date: Mon, 13 Jun 2011 17:31:51 -0400 (EDT)
Message-ID: <20110613.173151.1142825424020011611.davem@davemloft.net>
References: <1307867229.2872.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab1FMVcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 17:32:09 -0400
In-Reply-To: <1307867229.2872.101.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 12 Jun 2011 10:27:09 +0200

> l2tp_ip_sendmsg() in non connected mode incorrectly calls
> sk_setup_caps(). Subsequent send() calls send data to wrong destination.
> 
> We can also avoid changing dst refcount in connected mode, using
> appropriate rcu locking. Once output route lookups can also be done
> under rcu, sendto() calls wont change dst refcounts too.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: James Chapman <jchapman@katalix.com>

Applied, thanks Eric.
