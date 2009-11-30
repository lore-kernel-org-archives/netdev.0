From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e100: Use pci pool to work around GFP_ATOMIC order 5
 memory allocation failure
Date: Sun, 29 Nov 2009 17:17:49 -0800 (PST)
Message-ID: <20091129.171749.113308677.davem@davemloft.net>
References: <200911261649.54785.roger.oksanen@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, akpm@linux-foundation.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, karol.k.lewandowski@gmail.com
To: roger.oksanen@cs.helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53818
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751622AbZK3BRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:17:43 -0500
In-Reply-To: <200911261649.54785.roger.oksanen@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Date: Thu, 26 Nov 2009 16:49:54 +0200

> e100: Use pci pool to work around GFP_ATOMIC order 5 memory allocation failure.
> 
> pci_alloc_consistent uses GFP_ATOMIC allocation that may fail on some systems
> with limited memory (Bug #14265). pci_pool_alloc allows waiting with
> GFP_KERNEL.
> 
> Tested-by: Karol Lewandowski <karol.k.lewandowski@gmail.com>
> Signed-off-by: Roger Oksanen <roger.oksanen@cs.helsinki.fi>

Looks good, thanks.

Applied to net-2.6 and queued up for -stable
