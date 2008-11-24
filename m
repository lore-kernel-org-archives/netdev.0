From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Make sure BHs are disabled in
 sock_prot_inuse_add()
Date: Mon, 24 Nov 2008 14:05:39 -0800 (PST)
Message-ID: <20081124.140539.142357065.davem@davemloft.net>
References: <492AE30C.70907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42071
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752150AbYKXWFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 17:05:39 -0500
In-Reply-To: <492AE30C.70907@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 24 Nov 2008 18:23:24 +0100

> Third round of patch about sock_prot_inuse_add() ...
> 
> Thanks
> 
> [PATCH] net: Make sure BHs are disabled in sock_prot_inuse_add()
> 
> There is still a call to sock_prot_inuse_add() in af_netlink
> while in a preemptable section. Add explicit BH disable around
> this call.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
