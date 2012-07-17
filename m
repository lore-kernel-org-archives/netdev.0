From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix RTPROT_RA markup of RA routes w/nexthops
Date: Mon, 16 Jul 2012 22:56:11 -0700 (PDT)
Message-ID: <20120716.225611.1570342975310166446.davem@davemloft.net>
References: <1405671341819473@web18d.yandex.ru>
	<20120709.144002.6394436211445151.davem@davemloft.net>
	<20120710184550.7a5a8d89802473b4c28d07bf@yandex.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: infrastation@yandex.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090Ab2GQF4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:56:12 -0400
In-Reply-To: <20120710184550.7a5a8d89802473b4c28d07bf@yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Ovsienko <infrastation@yandex.ru>
Date: Tue, 10 Jul 2012 18:45:50 +0400

> From: Denis Ovsienko <infrastation@yandex.ru>
> 
> Userspace implementations of network routing protocols sometimes need to
> tell RA-originated IPv6 routes from other kernel routes to make proper
> routing decisions. This makes most sense for RA routes with nexthops,
> namely, default routes and Route Information routes.
> 
> The intended mean of preserving RA route origin in a netlink message is
> through indicating RTPROT_RA as protocol code. Function rt6_fill_node()
> tried to do that for default routes, but its test condition was taken
> wrong. This change is modeled after the original mailing list posting
> by Jeff Haran. It fixes the test condition for default route case and
> sets the same behaviour for Route Information case (both types use
> nexthops). Handling of the 3rd RA route type, Prefix Information, is
> left unchanged, as it stands for interface connected routes (without
> nexthops).
> 
> Signed-off-by: Denis Ovsienko <infrastation@yandex.ru>

Applied to net-next, thanks.
