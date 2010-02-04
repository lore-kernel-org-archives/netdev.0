From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2 1/2] ixgbe: Allocate driver resources
 per NUMA node
Date: Wed, 03 Feb 2010 19:49:01 -0800 (PST)
Message-ID: <20100203.194901.263092541.davem@davemloft.net>
References: <20100204001804.15798.98344.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43961
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755976Ab0BDDss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 22:48:48 -0500
In-Reply-To: <20100204001804.15798.98344.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 03 Feb 2010 16:18:50 -0800

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> The default policy for the current driver is to do all its memory
> allocation on whatever processor is running insmod/modprobe.  This
> is less than optimal.
> 
> This driver's default mode of operation will be to use each node for each
> subsequent transmit/receive queue.  The most efficient allocation will be
> to then have the interrupts bound in such a way as to match up the
> interrupt of the queue to the cpu where its memory was allocated.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
