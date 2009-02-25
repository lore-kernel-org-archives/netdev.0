From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/2] ixbge: fix bug when using large pages and
 jumbo frames
Date: Tue, 24 Feb 2009 16:37:41 -0800 (PST)
Message-ID: <20090224.163741.23168667.davem@davemloft.net>
References: <20090224234037.29312.54427.stgit@lost.foo-projects.org>
	<20090224234056.29312.78842.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com, leitao@linux.vnet.ibm.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40441
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752869AbZBYAh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 19:37:57 -0500
In-Reply-To: <20090224234056.29312.78842.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 24 Feb 2009 15:40:56 -0800

> it was pointed out on the list that ixgbe was failing when using 64kB pages
> and large 16kB MTU.
> 
> since with a 64kB PAGE_SIZE MAX_SKB_FRAGS = 3, the way the driver was
> configuring page usage was assuming 2kB is half a page, and was only
> ever dmaing that much data to a half page.
> 
> (16kB - header size) / 2048 = 7 or 8 pages, which would far exceed 3
> 
> adjust the driver to account for these large pages, the hardware can
> support DMA to up to 16kB for each descriptor.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
