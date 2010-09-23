From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 4/6] e1000e: 82579 unaccounted missed packets
Date: Wed, 22 Sep 2010 21:11:04 -0700 (PDT)
Message-ID: <20100922.211104.98876899.davem@davemloft.net>
References: <20100923031432.10976.81909.stgit@localhost.localdomain>
	<20100923031617.10976.68976.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40244
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751013Ab0IWEKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 00:10:44 -0400
In-Reply-To: <20100923031617.10976.68976.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Sep 2010 20:16:18 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> On 82579, there is a hardware bug that can cause received packets to not
> get transferred from the PHY to the MAC due to K1 (a power saving feature
> of the PHY-MAC interconnect similar to ASPM L1).  Since the MAC controls
> the accounting of missed packets, these will go unnoticed.  Workaround the
> issue by setting the K1 beacon duration according to the link speed.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
