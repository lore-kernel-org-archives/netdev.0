From: David Miller <davem@davemloft.net>
Subject: Re: [next-next-2.6 PATCH] enic: Add support to configure hardware
 interrupt coalesce timers in a platform independent way
Date: Fri, 17 Jun 2011 15:25:43 -0400 (EDT)
Message-ID: <20110617.152543.2216040030701311621.davem@davemloft.net>
References: <20110617175648.5502.43785.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932429Ab1FQTZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 15:25:49 -0400
In-Reply-To: <20110617175648.5502.43785.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Fri, 17 Jun 2011 10:56:48 -0700

> From: Vasanthy Kolluri <vkolluri@cisco.com>
> 
> enic driver and the underlying hardware use different units for representing the interrupt coalesce timer.
> Driver converts the interrupt coalesce timer in usec to hardware cycles while setting the relevant hardware
> registers. The conversion factor can be different for each of the adapter hardware types. So it is dynamically
> learnt from the adapter firmware using the devcmd CMD_INTR_COAL_CONVERT. This allows the driver to configure
> the hardware interrupt coalesce timers in a platform independent way.
> 
> Signed-off-by: Danny Guo <dannguo@cisco.com>
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

Applied.
