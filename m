From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/1] net: tcp: Increase TCP_MIB_OUTRSTS even
 though fail to alloc skb
Date: Sat, 08 Apr 2017 08:30:42 -0700 (PDT)
Message-ID: <20170408.083042.350729960635338681.davem@davemloft.net>
References: <1491491149-30701-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        ncardwell@google.com, netdev@vger.kernel.org, fgao@ikuai8.com
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751137AbdDHPao (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 11:30:44 -0400
In-Reply-To: <1491491149-30701-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@foxmail.com
Date: Thu,  6 Apr 2017 23:05:49 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> Because TCP_MIB_OUTRSTS is an important count, so always increase it
> whatever send it successfully or not.
> 
> Now move the increment of TCP_MIB_OUTRSTS to the top of
> tcp_send_active_reset to make sure it is increased always even though
> fail to alloc skb.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied, thank you.
