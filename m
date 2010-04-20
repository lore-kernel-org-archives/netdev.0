From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Tue, 20 Apr 2010 01:18:26 -0700 (PDT)
Message-ID: <20100420.011826.86913718.davem@davemloft.net>
References: <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>
	<1271743164.3845.128.camel@edumazet-laptop>
	<1271750198.3845.216.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37201
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751566Ab0DTISW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 04:18:22 -0400
In-Reply-To: <1271750198.3845.216.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Apr 2010 09:56:38 +0200

> In case we compute a software skb->rxhash, we can generate a consistent
> hash : Its value will be the same in both flow directions.
> 
> This helps some workloads, like conntracking, since the same state needs
> to be accessed in both directions.
> 
> tbench + RFS + this patch gives better results than tbench with default
> kernel configuration (no RPS, no RFS)
> 
> Also fixed some sparse warnings.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
