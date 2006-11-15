From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/3] node-aware skb allocations
Date: Wed, 15 Nov 2006 15:16:46 -0800
Message-ID: <20061115151646.9c8a6936.akpm@osdl.org>
References: <20061115173643.GA17695@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20407 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162059AbWKOXQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 18:16:55 -0500
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20061115173643.GA17695@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Nov 2006 18:36:43 +0100
Christoph Hellwig <hch@lst.de> wrote:

> This is the final version of the node-aware skb allocations,
> implementing davem's suggestion of storing the numa node in
> struct device.  I'd love to get this into 2.6.20 now that I
> don't hear negative comments about it anymre, but I wonder
> how.  The first patch toches mm/slab.c, the second struct device
> and assorted files and only the last one is actually in the networking
> code.  Should Dave push all this through net-2.6.20 or should we
> get it in purely through -mm?

If Dave wants to nod at it then I can merge all of it, else I can hand
patch 3/3 over to Dave once its prerequisites are in mainline.

