From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Set the filter
 Hardware device for all use-cases
Date: Mon, 05 Dec 2016 15:07:23 -0500 (EST)
Message-ID: <20161205.150723.9298784745370879.davem@davemloft.net>
References: <1480857919-25194-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au, jiri@mellanox.com,
        ogerlitz@mellanox.com
To: hadarh@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49992 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751895AbcLEUOj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 15:14:39 -0500
In-Reply-To: <1480857919-25194-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>
Date: Sun,  4 Dec 2016 15:25:19 +0200

> Check if the returned device from tcf_exts_get_dev function supports tc
> offload and in case the rule can't be offloaded, set the filter hw_dev
> parameter to the original device given by the user.
> 
> The filter hw_device parameter should always be set by fl_hw_replace_filter
> function, since this pointer is used by dump stats and destroy
> filter for each flower rule (offloaded or not).
> 
> Fixes: 7091d8c7055d ('net/sched: cls_flower: Add offload support using egress Hardware device')
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Reported-by: Simon Horman <horms@verge.net.au>

Applied, thank you.
