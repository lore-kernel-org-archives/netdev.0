From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rpc_rdma: we need to cast u64 to unsigned long long
 for printing
Date: Tue, 30 Oct 2007 00:44:46 -0700 (PDT)
Message-ID: <20071030.004446.219023926.davem@davemloft.net>
References: <20071030161240.bc81cad3.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47545
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752958AbXJ3HpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 03:45:05 -0400
In-Reply-To: <20071030161240.bc81cad3.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 30 Oct 2007 16:12:40 +1100

> as some architectures have unsigned long for u64.
> 
> net/sunrpc/xprtrdma/rpc_rdma.c: In function 'rpcrdma_create_chunks':
> net/sunrpc/xprtrdma/rpc_rdma.c:222: warning: format '%llx' expects type 'long long unsigned int', but argument 4 has type 'u64'
> net/sunrpc/xprtrdma/rpc_rdma.c:234: warning: format '%llx' expects type 'long long unsigned int', but argument 5 has type 'u64'
> net/sunrpc/xprtrdma/rpc_rdma.c: In function 'rpcrdma_count_chunks':
> net/sunrpc/xprtrdma/rpc_rdma.c:577: warning: format '%llx' expects type 'long long unsigned int', but argument 4 has type 'u64
> 
> Noticed on PowerPC pseries_defconfig build.
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

I've applied this, thanks Stephen.
