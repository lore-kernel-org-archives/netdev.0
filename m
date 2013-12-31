From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 0/2] net/mlx4: Add support for TCP/IP
 offloads of vxlan tunneling
Date: Tue, 31 Dec 2013 14:32:16 -0500 (EST)
Message-ID: <20131231.143216.1678016898138338054.davem@davemloft.net>
References: <1387807784-22056-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, yanb@mellanox.com,
	ast@plumgrid.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756502Ab3LaTcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 14:32:17 -0500
In-Reply-To: <1387807784-22056-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Mon, 23 Dec 2013 16:09:42 +0200

> These two patches add mlx4 support for TCP/IP offloads under vxlan tunneling.
> 
> changes from V2:
>  - applied feedback from Dave to avoid lisp stype double brackets
> 
> changes from V1:
>  - applied feedback from Joe Perches: fixed an overly indented line, made a variable bool
>    instead of int, initialize dev->hw_enc_features with |= to take into account
>    setting done by the networking core during register_netdevice
> 
> changes from V0:
>  - rebased against net-next commit 289dccb "net: use kfree_skb_list() helper",
>    to avoid git am failure as of content change

Both applied, thanks.
