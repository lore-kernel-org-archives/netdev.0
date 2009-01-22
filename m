From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: Fix oops in suspend/resume paths
Date: Thu, 22 Jan 2009 13:51:54 -0800 (PST)
Message-ID: <20090122.135154.96272626.davem@davemloft.net>
References: <20090122180930.GA27624@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47679
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752819AbZAVVvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 16:51:52 -0500
In-Reply-To: <20090122180930.GA27624@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Thu, 22 Jan 2009 21:09:30 +0300

> Suspend/resume routines check for phydrv != NULL, but that is
> wrong because "phydrv" comes from container_of(drv). If drv is NULL,
> then container_of(drv) will return non-NULL result, and the checks
> won't work.
> 
> The Freescale TBI PHYs are driver-less, so "drv" is NULL, and that
> leads to the following oops:
 ...
> This patch fixes the issue, plus removes unneeded parentheses
> and fixes indentation level in mdio_bus_suspend().
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied, thanks Anton.
