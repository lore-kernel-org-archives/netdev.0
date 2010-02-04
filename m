From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2 2/2] ixgbe: Make descriptor ring
 allocations NUMA-aware
Date: Wed, 03 Feb 2010 19:49:07 -0800 (PST)
Message-ID: <20100203.194907.261892375.davem@davemloft.net>
References: <20100204001804.15798.98344.stgit@localhost.localdomain>
	<20100204001910.15798.50480.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43966
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756595Ab0BDDsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 22:48:53 -0500
In-Reply-To: <20100204001910.15798.50480.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 03 Feb 2010 16:19:12 -0800

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> This patch allocates the ring structures themselves on each
> NUMA node along with the buffer_info structures.  This way we
> don't allocate the entire ring memory on a single node in one
> big block, thus reducing NUMA node memory crosstalk.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
