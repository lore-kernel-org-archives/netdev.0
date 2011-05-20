From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: fix panic if lowerdev in a bond
Date: Fri, 20 May 2011 14:59:52 -0400 (EDT)
Message-ID: <20110520.145952.462307683994245367.davem@davemloft.net>
References: <1305909889.3173.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, jpirko@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754803Ab1ETTBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 15:01:01 -0400
In-Reply-To: <1305909889.3173.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 May 2011 18:44:49 +0200

> commit a35e2c1b6d905 (macvlan: use rx_handler_data pointer to store
> macvlan_port pointer V2) added a bug in macvlan_port_create()
> 
> Steps to reproduce the bug:
> 
> # ifenslave bond0 eth0 eth1
> 
> # ip link add link eth0 up name eth0#1 type macvlan
> ->error EBUSY
> 
> # ip link add link eth0 up name eth0#1 type macvlan
> ->panic
> 
> 
> Fix: Dont set IFF_MACVLAN_PORT in error case.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks.
