From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 08/12] e1000e: Incorrect function pointer
 set for force_speed_duplex on 82577
Date: Wed, 12 May 2010 23:32:22 -0700 (PDT)
Message-ID: <20100512.233222.260080652.davem@davemloft.net>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
	<20100511010128.30827.12447.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45041
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754193Ab0EMGcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 02:32:14 -0400
In-Reply-To: <20100511010128.30827.12447.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 10 May 2010 18:01:30 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The force_speed_duplex function pointer was incorrectly set.  Instead of
> calling the 82577-specific version it was calling the m88 version which,
> among other incorrect things, reset the PHY causing autonegotiation to be
> re-enabled in the PHY resulting in the link defaulting to half-duplex.
> The 82577-specific force_speed_duplex function also had an issue where
> it disabled Auto-MDI-X which caused the link to not come up.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
