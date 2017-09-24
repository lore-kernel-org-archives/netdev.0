From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] forcedeth: optimize the xmit/rx with unlikely
Date: Sat, 23 Sep 2017 20:04:50 -0700 (PDT)
Message-ID: <20170923.200450.1594455070872157908.davem@davemloft.net>
References: <1506090021-16489-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, netdev@vger.kernel.org
To: yanjun.zhu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44410 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751563AbdIXDEv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 23:04:51 -0400
In-Reply-To: <1506090021-16489-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@oracle.com>
Date: Fri, 22 Sep 2017 10:20:21 -0400

> In the xmit/rx fastpath, the function dma_map_single rarely fails.
> Therefore, add an unlikely() optimization to this error check
> conditional.
> 
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>

Applied to net-next, thanks.
