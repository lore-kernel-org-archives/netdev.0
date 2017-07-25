From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: remove redundant argument from
 tcp_rcv_established()
Date: Mon, 24 Jul 2017 17:28:24 -0700 (PDT)
Message-ID: <20170724.172824.2284547257396708278.davem@davemloft.net>
References: <187C550C-E5E9-45E7-BC6C-20431B6883E0@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45344 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752857AbdGYA2Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 20:28:25 -0400
In-Reply-To: <187C550C-E5E9-45E7-BC6C-20431B6883E0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilya Matveychikov <matvejchikov@gmail.com>
Date: Mon, 24 Jul 2017 16:02:12 +0400

> The last (4th) argument of tcp_rcv_established() is redundant as it
> always equals to skb->len and the skb itself is always passed as 2th
> agrument. There is no reason to have it.
> 
> Signed-off-by: Ilya V. Matveychikov <matvejchikov@gmail.com>

Applied to net-next, thanks.
