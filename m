From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 00/11] net/mlx5: ConnectX-4 100G Ethernet
 driver
Date: Mon, 13 Apr 2015 22:15:22 -0400 (EDT)
Message-ID: <20150413.221522.162480193486167425.davem@davemloft.net>
References: <1428925501-2373-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com, saeedm@mellanox.com,
	ogerlitz@mellanox.com, achiad@mellanox.com, idos@mellanox.com,
	talal@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbbDNCP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 22:15:26 -0400
In-Reply-To: <1428925501-2373-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon, 13 Apr 2015 14:44:50 +0300

> - Removed V0 Patch 1/11 ("net/mlx5_core: Virtually extend work/completion queue
>   buffers by one page") due to misuse of DMA API. Thanks Dave.

I don't know how stupid you think I am....

You may have removed the patch that did the refactoring, but the
completely broken code misusing the DMA API is still there in this
driver.

I said I want you to fix this fundamental problem with your driver
before making major changes like this series to it.

And I really meant it.

Don't try to side step the issue in the way that you did here.

Thanks.
