From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix memory leak in the proto_register function
Date: Fri, 21 Nov 2008 16:45:33 -0800 (PST)
Message-ID: <20081121.164533.133749247.davem@davemloft.net>
References: <20081121125628.11468.72009.stgit@pc1117.cambridge.arm.com>
	<20081121140808.GA20958@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: catalin.marinas@arm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36950
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753669AbYKVApe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:45:34 -0500
In-Reply-To: <20081121140808.GA20958@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 21 Nov 2008 12:08:08 -0200

> Please send networking patches to netdev@vger.kernel.org as well.
 ...
> If the slub allocator is used, kmem_cache_create() may merge two or more
> kmem_cache's into one but the cache name pointer is not updated and
> kmem_cache_name() is no longer guaranteed to return the pointer passed
> to the former function. This patch stores the kmalloc'ed pointers in the
> corresponding request_sock_ops and timewait_sock_ops structures.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
> 

Applied, thanks everyone.
