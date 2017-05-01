From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] rhashtable: compact struct
 rhashtable_params
Date: Mon, 01 May 2017 16:22:58 -0400 (EDT)
Message-ID: <20170501.162258.533759204785263430.davem@davemloft.net>
References: <20170501201801.17344-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37250 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750802AbdEAUXo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 16:23:44 -0400
In-Reply-To: <20170501201801.17344-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon,  1 May 2017 22:18:01 +0200

> By using smaller datatypes this (rather large) struct shrinks considerably
> (80 -> 48 bytes on x86_64).
> 
> As this is embedded in other structs, this also rerduces size of several
> others, e.g. cls_fl_head or nft_hash.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  changes since v1: rebase on top of net-next master
> 
>  David, if its too late, just mark this as deferred in patchwork
>  and I'll resubmit when net-next reopens.

It's fine, I asked you to respin.

Applied, thanks Florian.
