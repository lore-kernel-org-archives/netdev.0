From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30 5/5] cxgb3: map entire Rx page, feed map+offset
 to Rx ring.
Date: Fri, 27 Mar 2009 00:53:42 -0700 (PDT)
Message-ID: <20090327.005342.73932167.davem@davemloft.net>
References: <20090327023909.32137.93884.stgit@speedy5>
	<20090327023929.32137.65704.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36378
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756321AbZC0Hxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:53:55 -0400
In-Reply-To: <20090327023929.32137.65704.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Thu, 26 Mar 2009 19:39:29 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> DMA mapping can be expensive in the presence of iommus.
> Reduce the Rx iommu activity by mapping an entire page, and provide the H/W
> the mapped address + offset of the current page chunk.
> Reserve bits at the end of the page to track mapping references, so the page
> can be unmapped.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
