From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: remove parameter rt from
 fib6_prune_clones()
Date: Mon, 12 May 2014 01:07:10 -0400 (EDT)
Message-ID: <20140512.010710.1360440297212614695.davem@davemloft.net>
References: <536C683F.40408@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbaELFHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 01:07:12 -0400
In-Reply-To: <536C683F.40408@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Fri, 9 May 2014 13:31:43 +0800

> the parameter rt will be assigned to c.arg in function fib6_clean_tree(),
> but function fib6_prune_clone() doesn't use c.arg, so we can remove it
> safely.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

This is fine, applied, thanks.
