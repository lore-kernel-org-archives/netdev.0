From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000: do not modify tx_queue_len on link
 speed change
Date: Sat, 27 Mar 2010 08:34:26 -0700 (PDT)
Message-ID: <20100327.083426.39178733.davem@davemloft.net>
References: <20100326212557.18793.62063.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, franco@lastsummer.de,
	emil.s.tantilov@intel.com, jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53713
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752158Ab0C0PeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 11:34:03 -0400
In-Reply-To: <20100326212557.18793.62063.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 26 Mar 2010 14:25:58 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Previously the driver tweaked txqueuelen to avoid false Tx hang reports
> seen at half duplex.  This had the effect of overriding user set values
> on link change/reset. Testing shows that adjusting only the timeout
> factor is sufficient to prevent Tx hang reports at half duplex.
> 
> This patch removes all instances of tx_queue_len in the driver.
> 
> Based on e1000e patch by Franco Fichtner <franco@lastsummer.de>
> 
> CC: Franco Fichtner <franco@lastsummer.de>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
