From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: Ignore budget on TX napi polling
Date: Tue, 08 Jul 2014 20:01:16 -0700 (PDT)
Message-ID: <20140708.200116.1002049422940185215.davem@davemloft.net>
References: <1404808092-29411-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754511AbaGIDBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 23:01:17 -0400
In-Reply-To: <1404808092-29411-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue,  8 Jul 2014 11:28:12 +0300

> It is recommended that TX work not count against the quota.
> The cost of TX packet liberation is a minute percentage of what it costs to
> process an RX frame. Furthermore, that SKB freeing makes memory available for
> other paths in the stack.
> 
> Give the TX a larger budget and be more aggressive about cleaning up the Tx
> descriptors this budget could be changed using ethtool:
> $ ethtool -C eth1 tx-frames-irq <budget>
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thanks for following up on this.
