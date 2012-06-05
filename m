From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] inetpeer: fix a race in inetpeer_gc_worker()
Date: Tue, 5 Jun 2012 15:09:54 +0200
Message-ID: <20120605130953.GG27795@secunet.com>
References: <1338901218.2760.2615.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53820 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392Ab2FENKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 09:10:01 -0400
Content-Disposition: inline
In-Reply-To: <1338901218.2760.2615.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 05, 2012 at 03:00:18PM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> commit 5faa5df1fa2024 (inetpeer: Invalidate the inetpeer tree along with
> the routing cache) added a race :
> 
> Before freeing an inetpeer, we must respect a RCU grace period, and make
> sure no user will attempt to increase refcnt.
> 
> inetpeer_invalidate_tree() waits for a RCU grace period before inserting
> inetpeer tree into gc_list and waking the worker. At that time, no
> concurrent lookup can find a inetpeer in this tree.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

Thaks again!
