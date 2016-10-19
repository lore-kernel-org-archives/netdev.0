From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: arc_emac: use dev_kfree_skb_any instead of
 dev_kfree_skb
Date: Wed, 19 Oct 2016 15:16:49 -0400 (EDT)
Message-ID: <20161019.151649.1017207144840174569.davem@davemloft.net>
References: <1476884872-15213-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wxt@rock-chips.com, al.kochet@gmail.com, tremyfr@gmail.com,
        peter.chen@nxp.com, weiyongjun1@huawei.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59734 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932977AbcJSTQv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 15:16:51 -0400
In-Reply-To: <1476884872-15213-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 19 Oct 2016 13:47:52 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in arc_emac_tx()
> which can be called from hard irq context (netpoll) and from
> other contexts. arc_emac_tx() only frees skbs that it has
> dropped.
> 
> This is detected by Coccinelle semantic patch.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
