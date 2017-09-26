From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vti: fix use after free in
 vti_tunnel_xmit/vti6_tnl_xmit
Date: Tue, 26 Sep 2017 10:13:44 -0700 (PDT)
Message-ID: <20170926.101344.586556748727836059.davem@davemloft.net>
References: <1506428069-4716-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
        herbert@gondor.apana.org.au
To: alexey.kodanev@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60168 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965047AbdIZRNp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 13:13:45 -0400
In-Reply-To: <1506428069-4716-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Tue, 26 Sep 2017 15:14:29 +0300

> When running LTP IPsec tests, KASan might report:
> 
> BUG: KASAN: use-after-free in vti_tunnel_xmit+0xeee/0xff0 [ip_vti]
> Read of size 4 at addr ffff880dc6ad1980 by task swapper/0/0
> ...
 ...
> Can be fixed if we get skb->len before dst_output().
> 
> Fixes: b9959fd3b0fa ("vti: switch to new ip tunnel code")
> Fixes: 22e1b23dafa8 ("vti6: Support inter address family tunneling.")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>

Applied and queued up for -stable.
