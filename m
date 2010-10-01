From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] e1000e: use hardware writeback
 batching
Date: Thu, 30 Sep 2010 21:16:57 -0700 (PDT)
Message-ID: <20100930.211657.63042041.davem@davemloft.net>
References: <20100930073814.13378.4212.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48260
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751086Ab0JAEQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 00:16:37 -0400
In-Reply-To: <20100930073814.13378.4212.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 30 Sep 2010 00:38:49 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Most e1000e parts support batching writebacks.  The problem with this is
> that when some of the TADV or TIDV timers are not set, Tx can sit forever.
> 
> This is solved in this patch with write flushes using the Flush Partial
> Descriptors (FPD) bit in TIDV and RDTR.
> 
> This improves bus utilization and removes partial writes on e1000e,
> particularly from 82571 parts in S5500 chipset based machines.
> 
> Only ES2LAN and 82571/2 parts are included in this optimization, to reduce
> testing load.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
