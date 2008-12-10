From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 2/2] igb: Correctly determine pci-e function
 number in virtual environment
Date: Wed, 10 Dec 2008 01:11:00 -0800 (PST)
Message-ID: <20081210.011100.167309841.davem@davemloft.net>
References: <20081210024156.27280.78618.stgit@lost.foo-projects.org>
	<20081210024216.27280.8218.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48467
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752837AbYLJJLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 04:11:00 -0500
In-Reply-To: <20081210024216.27280.8218.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 09 Dec 2008 18:42:16 -0800

> When running in a virtual environment the ports of an 82575/6 can appear to
> be single function devices which is not correct.  To resolve this we rely
> on the function number stored in the status register.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Also applied, thanks!

I noticed that there is a LRO Kconfig option for this driver.
That should be eliminated and LRO enabled by default since
for the cases where LRO causes trouble (routing, bridging,
etc.) we'll make ethtool calls to disable LRO on the device.
