From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: fix broken build.
Date: Thu, 23 Aug 2012 09:29:54 -0700 (PDT)
Message-ID: <20120823.092954.400957330511761110.davem@davemloft.net>
References: <309002C0DA137042828828FC53D7A934012B21B8CCCE@IL-MB01.marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@parallels.com, edumazet@google.com
To: rosenr@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048Ab2HWQ34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 12:29:56 -0400
In-Reply-To: <309002C0DA137042828828FC53D7A934012B21B8CCCE@IL-MB01.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <rosenr@marvell.com>
Date: Thu, 23 Aug 2012 15:55:41 +0300

> This patch fixes a broken build due to a missing header: 
> ...
>   CC      net/ipv4/proc.o
> In file included from include/net/net_namespace.h:15,
>                  from net/ipv4/proc.c:35:
> include/net/netns/packet.h:11: error: field 'sklist_lock' has incomplete type
> ...
> 
> The lock of netns_packet has been replaced by a recent patch to be a mutex instead of a spinlock, 
> but we need to replace the header file to be linux/mutex.h instead of linux/spinlock.h as well.
> 
> See commit 0fa7fa98dbcc2789409ed24e885485e645803d7f:
> packet: Protect packet sk list with mutex (v2) patch, 
> 
> Signed-off-by: Rami Rosen <rosenr@marvell.com>

Applied, thanks.
