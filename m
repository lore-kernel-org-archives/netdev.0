From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro_cells: remove spinlock protecting receive
 queues
Date: Mon, 31 Aug 2015 15:17:33 -0700 (PDT)
Message-ID: <20150831.151733.34067376878999701.davem@davemloft.net>
References: <1441054654.8932.159.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753645AbbHaWRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 18:17:33 -0400
In-Reply-To: <1441054654.8932.159.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 31 Aug 2015 13:57:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> As David pointed out, spinlock are no longer needed
> to protect the per cpu queues used in gro cells infrastructure.
> 
> Also use new napi_complete_done() API so that gro_flush_timeout
> tweaks have an effect.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
