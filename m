From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3] neigh: remove dynamic neigh table
 registration support
Date: Tue, 11 Nov 2014 15:31:02 -0500 (EST)
Message-ID: <20141111.153102.1989434431470303686.davem@davemloft.net>
References: <1415663976-7507-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33220 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453AbaKKUbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 15:31:05 -0500
In-Reply-To: <1415663976-7507-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 10 Nov 2014 15:59:36 -0800

> Currently there are only three neigh tables in the whole kernel:
> arp table, ndisc table and decnet neigh table. What's more,
> we don't support registering multiple tables per family.
> Therefore we can just make these tables statically built-in.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
> v3: fix neigh_table_clear()
> v2: remove useless #ifdef's
>     move the assignment to the end of neigh_table_init()

This looks a lot better, applied, thanks!
