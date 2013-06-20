From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: don't call addrconf_dst_alloc again when enable
 lo
Date: Wed, 19 Jun 2013 23:05:32 -0700 (PDT)
Message-ID: <20130619.230532.1329281330568271336.davem@davemloft.net>
References: <1371352470-3226-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kumaran.4353@gmail.com, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753363Ab3FTGFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 02:05:33 -0400
In-Reply-To: <1371352470-3226-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Sun, 16 Jun 2013 11:14:30 +0800

> If we disable all of the net interfaces, and enable
> un-lo interface before lo interface, we already allocated
> the addrconf dst in ipv6_add_addr. So we shouldn't allocate
> it again when we enable lo interface.
> 
> Otherwise the message below will be triggered.
> unregister_netdevice: waiting for sit1 to become free. Usage count = 1
> 
> This problem is introduced by commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
> "net IPv6 : Fix broken IPv6 routing table after loopback down-up"
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

This is the second such regression added by that commit :-/

Applied and queue up for -stable, thanks.
