From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] e1000e: MDIO slow mode should always be
 done for 82577
Date: Wed, 13 Jan 2010 17:15:40 -0800 (PST)
Message-ID: <20100113.171540.37629799.davem@davemloft.net>
References: <20100113115248.23394.71869.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58590
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754369Ab0ANBPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 20:15:31 -0500
In-Reply-To: <20100113115248.23394.71869.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 Jan 2010 03:52:49 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> A previous 82577 workaround that set the MDIO access speed to slow mode for
> every PHY register read/write when the cable is unplugged should instead
> set the access mode to always be slow before any PHY register access.
> Since the mode bit gets cleared when the PHY is reset, set the mode after
> every PHY reset.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
