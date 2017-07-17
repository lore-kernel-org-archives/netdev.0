From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Revert "net: add function to allocate
 sk_buff head without data area"
Date: Mon, 17 Jul 2017 10:34:35 -0700 (PDT)
Message-ID: <20170717.103435.730183661414504947.davem@davemloft.net>
References: <20170717165654.20026-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54530 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdGQReg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 13:34:36 -0400
In-Reply-To: <20170717165654.20026-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 17 Jul 2017 18:56:54 +0200

> It was added for netlink mmap tx, there are no callers in the tree.
> The commit also added a check for skb->head != NULL in kfree_skb path,
> remove that too -- all skbs ought to have skb->head set.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
