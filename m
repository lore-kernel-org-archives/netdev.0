From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: replace dma_sync_single with
 dma_sync_single_for_cpu
Date: Fri, 29 May 2009 01:51:49 -0700 (PDT)
Message-ID: <20090529.015149.92225019.davem@davemloft.net>
References: <20090528100925H.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49217
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751047AbZE2Ivt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:51:49 -0400
In-Reply-To: <20090528100925H.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Thu, 28 May 2009 10:10:42 +0900

> This replaces dma_sync_single() with dma_sync_single_for_cpu() because
> dma_sync_single() is an obsolete API; include/linux/dma-mapping.h says:
> 
> /* Backwards compat, remove in 2.7.x */
> #define dma_sync_single		dma_sync_single_for_cpu
> #define dma_sync_sg		dma_sync_sg_for_cpu
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Applied to net-next-2.6, thank you.
