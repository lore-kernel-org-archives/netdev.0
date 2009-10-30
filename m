From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e100: e100_phy_init() isolates selected PHY,
 causes 10 second boot delay
Date: Thu, 29 Oct 2009 22:54:21 -0700 (PDT)
Message-ID: <20091029.225421.37226161.davem@davemloft.net>
References: <20091029234228.5100.17917.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bernhard.kaindl@gmx.net,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49107
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755587AbZJ3Fx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 01:53:57 -0400
In-Reply-To: <20091029234228.5100.17917.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 29 Oct 2009 16:42:41 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> A change in how PHYs are electrically isolated caused all PHYs to be
> isolated followed by reverting that isolation for the selected PHY.
> Unfortunately, isolating the selected PHY for even a short period of
> time can result in DHCP negotiation taking more than 10 seconds on certain
> embedded configurations delaying boot time as reported by Bernhard Kaindl.
> This patch reverts the change to how PHYs are isolated yet still works
> around the issue for 82552 needing the selected PHY's BMCR register to
> be written after the unused PHYs are isolated.  This code is moved below
> the setting of nic->phy ID in order to do the 82552-specific workaround.
> 
> Cc: Bernhard Kaindl <bernhard.kaindl@gmx.net>
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
