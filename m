From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: Set flow*_dport when doing route lookups
Date: Tue, 10 Jan 2017 21:10:04 -0500 (EST)
Message-ID: <20170110.211004.1712612611986550798.davem@davemloft.net>
References: <20170110172945.24676-1-martynas@weave.works>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: martynas@weave.works
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935891AbdAKCKG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 21:10:06 -0500
In-Reply-To: <20170110172945.24676-1-martynas@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martynas Pumputis <martynas@weave.works>
Date: Tue, 10 Jan 2017 17:29:45 +0000

> Otherwise, no xfrm policy with dport being set can be matched.
> 
> Signed-off-by: Martynas Pumputis <martynas@weave.works>

And likewise you should also be adding the source port, since it is
available, to the route lookup as well.
