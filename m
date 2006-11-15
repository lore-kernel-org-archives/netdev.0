From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 0/3] node-aware skb allocations
Date: Wed, 15 Nov 2006 18:36:43 +0100
Message-ID: <20061115173643.GA17695@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:48308 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1030757AbWKORhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 12:37:08 -0500
To: akpm@osdl.org, davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the final version of the node-aware skb allocations,
implementing davem's suggestion of storing the numa node in
struct device.  I'd love to get this into 2.6.20 now that I
don't hear negative comments about it anymre, but I wonder
how.  The first patch toches mm/slab.c, the second struct device
and assorted files and only the last one is actually in the networking
code.  Should Dave push all this through net-2.6.20 or should we
get it in purely through -mm?
