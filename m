From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: fix link issues and panic with
 shared interrupts for 82598
Date: Thu, 30 Sep 2010 21:16:52 -0700 (PDT)
Message-ID: <20100930.211652.25148427.davem@davemloft.net>
References: <20100930073251.12750.67720.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751086Ab0JAEQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 00:16:31 -0400
In-Reply-To: <20100930073251.12750.67720.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 30 Sep 2010 00:35:23 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Fix possible panic/hang with shared Legacy interrupts by not enabling
> interrupts when interface is down.
> 
> Also fixes an intermittent link by enabling LSC upon exit from ixgbe_intr()
> 
> This patch adds flags to ixgbe_irq_enable() to allow for some flexibility
> when enabling interrupts.
> 
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
