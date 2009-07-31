From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] ixgbe: Fix RSC completion delay causing Rx
 interrupts to stop
Date: Thu, 30 Jul 2009 19:29:13 -0700 (PDT)
Message-ID: <20090730.192913.166256636.davem@davemloft.net>
References: <20090730222501.26121.2952.stgit@localhost.localdomain>
	<20090730222559.26121.13496.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37773
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752798AbZGaC3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 22:29:05 -0400
In-Reply-To: <20090730222559.26121.13496.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 30 Jul 2009 15:26:00 -0700

> When a user disables interrupt throttling with ethtool on 82599 devices,
> the interrupt timer may not be re-enabled if hardware RSC is running.  The
> RSC completions in hardware don't complete before the next ITR event tries
> to fire, so the ITR timer never gets re-armed.  This patch increases the
> amount of time between interrupts when throttling is disabled (rx-usecs =
> 0) when the hardware RSC deature is enabled.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
