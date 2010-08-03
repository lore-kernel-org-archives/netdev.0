From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igb: Program MDICNFG register prior to
 PHY init
Date: Tue, 03 Aug 2010 16:41:16 -0700 (PDT)
Message-ID: <20100803.164116.183063109.davem@davemloft.net>
References: <20100803215005.5948.63055.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57642
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757872Ab0HCXk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 19:40:57 -0400
In-Reply-To: <20100803215005.5948.63055.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 03 Aug 2010 14:50:08 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch addresses an issue seen on 82580 in which the MDICNFG
> register will be reset during a single function reset and as a
> result we will be unable to communicate with the PHY.  To correct
> the issue, added a call to reset_mdicnfg just prior to the first
> access of the MDICNFG register in sgnii_uses_mdio.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Also applied, thanks.
