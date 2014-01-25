From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: reallocate addrconf router for ipv6
 address when lo device up
Date: Fri, 24 Jan 2014 16:00:05 -0800 (PST)
Message-ID: <20140124.160005.687359123475903930.davem@davemloft.net>
References: <1390552151-20735-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net,
	hannes@stressinduktion.org, chenweilong@huawei.com
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbaAYAAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 19:00:06 -0500
In-Reply-To: <1390552151-20735-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Fri, 24 Jan 2014 16:29:11 +0800

> commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
> "net IPv6 : Fix broken IPv6 routing table after loopback down-up"
> allocates addrconf router for ipv6 address when lo device up.
> but commit a881ae1f625c599b460cc8f8a7fcb1c438f699ad
> "ipv6:don't call addrconf_dst_alloc again when enable lo" breaks
> this behavior.
> 
> Since the addrconf router is moved to the garbage list when
> lo device down, we should release this router and rellocate
> a new one for ipv6 address when lo device up.
> 
> This patch solves bug 67951 on bugzilla
> https://bugzilla.kernel.org/show_bug.cgi?id=67951
> 
> change from v1:
> use ip6_rt_put to repleace ip6_del_rt, thanks Hannes!
> change code style, suggested by Sergei.
> 
> CC: Sabrina Dubroca <sd@queasysnail.net>
> CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Reported-by: Weilong Chen <chenweilong@huawei.com>
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied and queued up for -stable, thanks!
