From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx5e: Avoid accessing NULL pointer at
 ndo_select_queue
Date: Tue, 25 Aug 2015 13:45:24 -0700 (PDT)
Message-ID: <20150825.134524.1830707997009616231.davem@davemloft.net>
References: <1440335534-31279-1-git-send-email-achiad@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ogerlitz@mellanox.com,
	saeedm@mellanox.com, talal@mellanox.com, ranas@mellanox.com
To: achiad@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbbHYUpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 16:45:25 -0400
In-Reply-To: <1440335534-31279-1-git-send-email-achiad@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>
Date: Sun, 23 Aug 2015 16:12:14 +0300

> From: Rana Shahout <ranas@mellanox.com>
> 
> To avoid multiply/division operations on the data path,
> we hold a {channel, tc}==>txq mapping table.
> We held this mapping table inside the channel object that is
> being destroyed upon some configuration operations (e.g MTU change).
> So in case ndo_select_queue occurs during such a configuration operation,
> it may access a NULL channel pointer, resulting in kernel panic.
> To fix this issue we moved the {channel, tc}==>txq mapping table
> outside the channel object so that it will be available also
> during such configuration operations.
> 
> 
> Signed-off-by: Rana Shahout <ranas@mellanox.com>

Applied, thanks.
