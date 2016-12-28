From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/sched: cls_flower: Fix missing addr_type in
 classify
Date: Wed, 28 Dec 2016 14:29:19 -0500 (EST)
Message-ID: <20161228.142919.404725916273031482.davem@davemloft.net>
References: <1482929687-20159-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, hadarh@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com
To: paulb@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44168 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751928AbcL1T3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 14:29:21 -0500
In-Reply-To: <1482929687-20159-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>
Date: Wed, 28 Dec 2016 14:54:47 +0200

> Since we now use a non zero mask on addr_type, we are matching on its
> value (IPV4/IPV6). So before this fix, matching on enc_src_ip/enc_dst_ip
> failed in SW/classify path since its value was zero.
> This patch sets the proper value of addr_type for encapsulated packets.
> 
> Fixes: 970bfcd09791 ('net/sched: cls_flower: Use mask for addr_type')
> Signed-off-by: Paul Blakey <paulb@mellanox.com>
> Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>

Applied and queued up for -stable, thanks.
