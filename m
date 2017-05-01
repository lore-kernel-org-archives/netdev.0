From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable: compact struct rhashtable_params
Date: Mon, 01 May 2017 14:55:57 -0400 (EDT)
Message-ID: <20170501.145557.1719363576330063674.davem@davemloft.net>
References: <20170427152809.6378-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36016 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdEASz6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 14:55:58 -0400
In-Reply-To: <20170427152809.6378-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 27 Apr 2017 17:28:09 +0200

> By using smaller datatypes this struct shrinks considerably
> (80 -> 48 bytes on x86_64).
> 
> As this is embedded in other structs, this also reduces size of several
> others, e.g. cls_fl_head and nft_hash.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

This doesn't apply to net-next cleanly, please respin.

Thanks.
