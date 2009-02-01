From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/3] ixgbe: Refactor MSI-X allocation mechanism
Date: Sun, 01 Feb 2009 01:19:37 -0800 (PST)
Message-ID: <20090201.011937.119375952.davem@davemloft.net>
References: <20090131010530.1820.5846.stgit@lost.foo-projects.org>
	<20090131010556.1820.28773.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34016
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752336AbZBAJTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 04:19:40 -0500
In-Reply-To: <20090131010556.1820.28773.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 30 Jan 2009 17:05:56 -0800

> Our current MSI-X allocation mechanism does not support new hardware
> at all.  It also isn't getting the actual number of supported MSI-X vectors
> from the device.
> 
> This patch allows the number of MSI-X vectors to be specific to a device,
> plus it gets the number of MSI-X vectors available from PCIe configuration
> space.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
