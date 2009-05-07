From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e1000/e1000e/igb/ixgb: don't txhang after
 link down
Date: Thu, 07 May 2009 14:56:37 -0700 (PDT)
Message-ID: <20090507.145637.154290988.davem@davemloft.net>
References: <20090507210734.20173.63453.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34467
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756313AbZEGV4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:56:43 -0400
In-Reply-To: <20090507210734.20173.63453.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 07 May 2009 14:07:35 -0700

> after the recent changes to wired drivers to use only
> netif_carrier_off the driver can have outstanding tx work to
> complete that will never complete once link is down.  Since the
> intel hardware will hold this tx work forever, the driver
> notices a tx timeout condition internally and might try
> to instigate printk and reset of the part with a
> netif_stop_queue, which doesn't work because link is down.
> 
> Don't bother arming to tx hang detection when link is down.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
