From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: core: Fix slab-out-of-bounds in
 netdev_stats_to_stats64
Date: Mon, 03 Jul 2017 02:41:01 -0700 (PDT)
Message-ID: <20170703.024101.611675879403798301.davem@davemloft.net>
References: <20170703012013.4009-1-alban.browaeys@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alban.browaeys@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54974 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753336AbdGCJlE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 05:41:04 -0400
In-Reply-To: <20170703012013.4009-1-alban.browaeys@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alban Browaeys <alban.browaeys@gmail.com>
Date: Mon,  3 Jul 2017 03:20:13 +0200

> commit 9256645af098 ("net/core: relax BUILD_BUG_ON in
> netdev_stats_to_stats64") made an attempt to read beyond
> the size of the source a possibility.
> 
> Fix to only copy src size to dest. As dest might be bigger than src.
 ...
> Signed-off-by: Alban Browaeys <alban.browaeys@gmail.com>

Applied and queued up for -stable, thanks.
