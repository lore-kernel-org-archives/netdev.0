From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/4] e1000e: do not touch PHY page 800
 registers when link speed is 1000Mbps
Date: Mon, 21 Jun 2010 13:43:08 -0700 (PDT)
Message-ID: <20100621.134308.189693840.davem@davemloft.net>
References: <20100618045804.6728.37945.stgit@localhost.localdomain>
	<20100618045904.6728.18894.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758352Ab0FUUm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 16:42:56 -0400
In-Reply-To: <20100618045904.6728.18894.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 17 Jun 2010 21:59:06 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The PHY on 82577/82578 has issues when the registers on page 800 are
> accessed when in gigabit mode.  Do not clear the Wakeup Control register
> when resetting the part since it is on page 800 (and will be cleared on
> reset anyway).
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
