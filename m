From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] ixgbe: Fix usage of netif_*_all_queues() with
 netif_carrier_{off|on}()
Date: Mon, 19 Jan 2009 16:55:30 -0800 (PST)
Message-ID: <20090119.165530.190679813.davem@davemloft.net>
References: <20090120001101.22544.15858.stgit@lost.foo-projects.org>
	<20090120001147.22544.97470.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43275
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757928AbZATAz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 19:55:28 -0500
In-Reply-To: <20090120001147.22544.97470.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 19 Jan 2009 16:11:47 -0800

> netif_carrier_off() is sufficient to stop Tx into the driver.  Stopping the Tx
> queues is redundant and unnecessary.  By the same token, netif_carrier_on()
> will be sufficient to re-enable Tx, so waking the queues is unnecessary.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
