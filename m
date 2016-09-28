From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Use a proper mask
 value for enc key id parameter
Date: Wed, 28 Sep 2016 03:11:42 -0400 (EDT)
Message-ID: <20160928.031142.334711547207526384.davem@davemloft.net>
References: <1474964478-4483-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirva@mellanox.com, jiri@mellanox.com,
        ogerlitz@mellanox.com
To: hadarh@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58612 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbcI1HLr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 03:11:47 -0400
In-Reply-To: <1474964478-4483-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>
Date: Tue, 27 Sep 2016 11:21:18 +0300

> The current code use the encapsulation key id value as the mask of that
> parameter which is wrong. Fix that by using a full mask.
> 
> Fixes: bc3103f1ed40 ('net/sched: cls_flower: Classify packet in ip tunnels')
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>

Applied, thanks.
