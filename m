From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2] ipv6: reallocate addrconf router for ipv6 address when lo device up
Date: Fri, 24 Jan 2014 14:32:13 +0100
Message-ID: <20140124133213.GP7269@order.stressinduktion.org>
References: <1390552151-20735-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Sabrina Dubroca <sd@queasysnail.net>,
	Weilong Chen <chenweilong@huawei.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34595 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbaAXNcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 08:32:14 -0500
Content-Disposition: inline
In-Reply-To: <1390552151-20735-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 24, 2014 at 04:29:11PM +0800, Gao feng wrote:
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

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks, Gao!
