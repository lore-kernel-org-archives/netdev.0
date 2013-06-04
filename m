From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: assign rt6_info to inet6_ifaddr in init_loopback
Date: Tue, 04 Jun 2013 16:58:14 -0700 (PDT)
Message-ID: <20130604.165814.116582759549567742.davem@davemloft.net>
References: <201305290029.35303.a.miskiewicz@gmail.com>
	<1370247381-3091-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	jasowang@redhat.com, kumaran.4353@gmail.com,
	Maruthi.Thotad@ap.sony.com
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252Ab3FDX6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 19:58:15 -0400
In-Reply-To: <1370247381-3091-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Mon, 3 Jun 2013 16:16:21 +0800

> Commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
> "net IPv6 : Fix broken IPv6 routing table after loopback down-up"
> forgot to assign rt6_info to the inet6_ifaddr.
> When disable the net device, the rt6_info which allocated
> in init_loopback will not be destroied in __ipv6_ifa_notify.
> 
> This will trigger the waring message below
> [23527.916091] unregister_netdevice: waiting for tap0 to become free. Usage count = 1
> 
> Reported-by: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Applied and queued up for -stable, thanks!
