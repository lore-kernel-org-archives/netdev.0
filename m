From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Remove the redundant skb->dev initialization
 in ip6_fragment
Date: Sat, 10 Jun 2017 16:25:52 -0400 (EDT)
Message-ID: <20170610.162552.484666339344324896.davem@davemloft.net>
References: <1497123338-16571-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, edumazet@google.com,
        fengc@google.com
To: chenbofeng.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34046 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdFJUZy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:25:54 -0400
In-Reply-To: <1497123338-16571-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Date: Sat, 10 Jun 2017 12:35:38 -0700

> From: Chenbo Feng <fengc@google.com>
> 
> After moves the skb->dev and skb->protocol initialization into
> ip6_output, setting the skb->dev inside ip6_fragment is unnecessary.
> 
> Fixes: 97a7a37a7b7b("ipv6: Initial skb->dev and skb->protocol in ip6_output")
> Signed-off-by: Chenbo Feng <fengc@google.com>

Applied, thank you.
