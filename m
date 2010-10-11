From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: percpu net_device refcount
Date: Mon, 11 Oct 2010 12:13:44 -0700 (PDT)
Message-ID: <20101011.121344.260085789.davem@davemloft.net>
References: <1286471555.2912.291.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50386
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751193Ab0JKTNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 15:13:22 -0400
In-Reply-To: <1286471555.2912.291.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Oct 2010 19:12:35 +0200

> We tried very hard to remove all possible dev_hold()/dev_put() pairs in
> network stack, using RCU conversions.
> 
> There is still an unavoidable device refcount change for every dst we
> create/destroy, and this can slow down some workloads (routers or some
> app servers)
> 
> We can switch to a percpu refcount implementation, now dynamic per_cpu
> infrastructure is mature. On a 64 cpus machine, this consumes 256 bytes
> per device.
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Ok, I'm fine with this.

But could you please get rid of that "#if 0" code block?  The comment
is fine and should stay, but the commented out code shouldn't really
stay there.

Thanks!
