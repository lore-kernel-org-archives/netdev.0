From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] dwc_eth_qos: use dev_kfree_skb_any instead of
 dev_kfree_skb
Date: Thu, 20 Oct 2016 14:48:44 -0400 (EDT)
Message-ID: <20161020.144844.667279135003325516.davem@davemloft.net>
References: <1476982789-27821-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44664 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933863AbcJTSsr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:48:47 -0400
In-Reply-To: <1476982789-27821-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 20 Oct 2016 16:59:49 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in dwceqos_start_xmit()
> which can be called from hard irq context (netpoll) and from
> other contexts. dwceqos_start_xmit() only frees skbs that it has
> dropped.
> 
> This is detected by Coccinelle semantic patch.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
