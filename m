From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: Fix alignment of rx queue bug
Date: Wed, 05 Sep 2012 17:45:43 -0400 (EDT)
Message-ID: <20120905.174543.111505618029273524.davem@davemloft.net>
References: <50469FC1.2000202@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755072Ab2IEVpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 17:45:44 -0400
In-Reply-To: <50469FC1.2000202@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santiago Leon <santil@linux.vnet.ibm.com>
Date: Tue, 04 Sep 2012 19:41:37 -0500

> This patch fixes a bug found by Nish Aravamudan 
> (https://lkml.org/lkml/2012/5/15/220) where the driver is not following
> the spec (it is not aligning the rx buffer on a 16-byte boundary) and the
> hypervisor aborts the registration, making the device unusable. 
> 
> The fix follows BenH's recommendation (https://lkml.org/lkml/2012/7/20/461)
> to replace the kmalloc+map for a single call to dma_alloc_coherent()
> because that function always aligns to a 16-byte boundary.
> 
> The stable trees will run into this bug whenever the rx buffer kmalloc call
> returns something not aligned on a 16-byte boundary.
> 
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>

Applied, thanks.
