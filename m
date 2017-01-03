From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drop_monitor: consider inserted data in genlmsg_end
Date: Tue, 03 Jan 2017 09:54:19 -0500 (EST)
Message-ID: <20170103.095419.261470619535526723.davem@davemloft.net>
References: <20170103003910.8984-1-wr0112358@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: wr0112358@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37054 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757212AbdACOyV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 09:54:21 -0500
In-Reply-To: <20170103003910.8984-1-wr0112358@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Reiter Wolfgang <wr0112358@gmail.com>
Date: Tue,  3 Jan 2017 01:39:10 +0100

> Final nlmsg_len field update must reflect inserted net_dm_drop_point
> data.
> 
> This patch depends on previous patch:
> "drop_monitor: add missing call to genlmsg_end"
> 
> Signed-off-by: Reiter Wolfgang <wr0112358@gmail.com>

I don't understand why the current code doesn't work properly.

All over the tree, the pattern is:

	x = genlmsg_put(skb, ...);
	...
	genlmsg_end(skb, x);

And that is exactly what the code is doing right now.
