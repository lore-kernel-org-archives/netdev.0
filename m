From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: autosize skb lengthes
Date: Mon, 10 Mar 2014 13:56:55 -0400 (EDT)
Message-ID: <20140310.135655.564901006977885920.davem@davemloft.net>
References: <1394222553.20149.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092AbaCJR46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:56:58 -0400
In-Reply-To: <1394222553.20149.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Mar 2014 12:02:33 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> One known problem with netlink is the fact that NLMSG_GOODSIZE is
> really small on PAGE_SIZE==4096 architectures, and it is difficult
> to know in advance what buffer size is used by the application.
> 
> This patch adds an automatic learning of the size.
> 
> First netlink message will still be limited to ~4K, but if user used
> bigger buffers, then following messages will be able to use up to 16KB.
> 
> This speedups dump() operations by a large factor and should be safe
> for legacy applications.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Thomas Graf <tgraf@suug.ch>

This looks great, applied, thanks!
