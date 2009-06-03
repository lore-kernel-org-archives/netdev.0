From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] fsl_pq_mido: Set the first UCC as the mii
 management interface master
Date: Wed, 03 Jun 2009 03:51:01 -0700 (PDT)
Message-ID: <20090603.035101.13573713.davem@davemloft.net>
References: <1243951456-4685-1-git-send-email-Haiying.Wang@freescale.com>
	<1243951456-4685-2-git-send-email-Haiying.Wang@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Haiying.Wang@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52901
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752717AbZFCKvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 06:51:00 -0400
In-Reply-To: <1243951456-4685-2-git-send-email-Haiying.Wang@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiying Wang <Haiying.Wang@freescale.com>
Date: Tue,  2 Jun 2009 10:04:14 -0400

> Current code makes the UCC whose register range includes the current mdio
> register to be the MII managemnt interface master of the QE. If there is more
> than one mdio bus for QE, the UCC of the last mdio bus will be the MII
> management interface master which will make the primary mdio bus working
> unproperly, e.g. can not get the right clock. Normally the primary mdio bus is
> the first UEC's mdio bus.
> This patch allows the first UCC to be the MII management interface master of the
> multiple UCC mdio buses.
> 
> Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>

Applied to net-next-2.6
