From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: Don't pass IP fragments to upper layer GRO
 handlers.
Date: Fri, 28 Apr 2017 16:01:00 -0400 (EDT)
Message-ID: <20170428.160100.968014134264728727.davem@davemloft.net>
References: <20170428085432.GH2649@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S642167AbdD1UBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 16:01:02 -0400
In-Reply-To: <20170428085432.GH2649@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 28 Apr 2017 10:54:32 +0200

> Upper layer GRO handlers can not handle IP fragments, so
> exit GRO processing in this case.
> 
> This fixes ESP GRO because the packet must be reassembled
> before we can decapsulate, otherwise we get authentication
> failures.
> 
> It also aligns IPv4 to IPv6 where packets with fragmentation
> headers are not passed to upper layer GRO handlers.
> 
> Fixes: 7785bba299a8 ("esp: Add a software GRO codepath")
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, thank you.
