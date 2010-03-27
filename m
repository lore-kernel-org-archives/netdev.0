From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] igbvf: do not modify tx_queue_len on link
 speed change
Date: Fri, 26 Mar 2010 21:01:56 -0700 (PDT)
Message-ID: <20100326.210156.39858849.davem@davemloft.net>
References: <20100325221120.8756.51559.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, franco@lastsummer.de,
	emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53333
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750742Ab0C0EBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 00:01:32 -0400
In-Reply-To: <20100325221120.8756.51559.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 25 Mar 2010 15:11:48 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Previously the driver tweaked txqueuelen to avoid false Tx hang reports seen at half duplex.
> This had the effect of overriding user set values on link change/reset. Testing shows that
> adjusting only the timeout factor is sufficient to prevent Tx hang reports at half duplex.
> 
> Based on e1000e patch by Franco Fichtner <franco@lastsummer.de>
> 
> CC: Franco Fichtner <franco@lastsummer.de>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
