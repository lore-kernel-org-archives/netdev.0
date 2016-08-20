From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/irda: remove pointless assignment/check
Date: Fri, 19 Aug 2016 18:07:55 -0700 (PDT)
Message-ID: <20160819.180755.2123553442134312293.davem@davemloft.net>
References: <20160819160857.32254-1-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, irda-users@lists.sourceforge.net,
        netdev@vger.kernel.org
To: vegard.nossum@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56248 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755529AbcHTBIQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 21:08:16 -0400
In-Reply-To: <20160819160857.32254-1-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vegard Nossum <vegard.nossum@oracle.com>
Date: Fri, 19 Aug 2016 18:08:57 +0200

> We've already set sk to sock->sk and dereferenced it, so if it's NULL
> we would have crashed already. Moreover, if it was NULL we would have
> crashed anyway when jumping to 'out' and trying to unlock the sock.
> Furthermore, if we had assigned a different value to 'sk' we would
> have been calling lock_sock() and release_sock() on different sockets.
> 
> My conclusion is that these two lines are complete nonsense and only
> serve to confuse the reader.
> 
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

Applied.
