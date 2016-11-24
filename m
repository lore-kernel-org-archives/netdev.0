From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net: revert "net: l2tp: Treat NET_XMIT_CN as
 success in l2tp_eth_dev_xmit"
Date: Wed, 23 Nov 2016 20:28:00 -0500 (EST)
Message-ID: <20161123.202800.1093755803785587463.davem@davemloft.net>
References: <1479799483-18332-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gfree.wind@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41952 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935508AbcKXB2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 20:28:02 -0500
In-Reply-To: <1479799483-18332-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 21 Nov 2016 23:24:43 -0800

> This reverts commit 7c6ae610a1f0, because l2tp_xmit_skb() never
> returns NET_XMIT_CN, it ignores the return value of l2tp_xmit_core().
> 
> Cc: Gao Feng <gfree.wind@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
