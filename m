From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: Fix WoL functionality for 82599 KX4
 devices
Date: Mon, 27 Apr 2009 03:14:57 -0700 (PDT)
Message-ID: <20090427.031457.254091404.davem@davemloft.net>
References: <20090423211514.29345.14658.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39868
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752895AbZD0KPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 06:15:04 -0400
In-Reply-To: <20090423211514.29345.14658.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 23 Apr 2009 14:15:18 -0700

> The current code writes the PME enabled bit in PCI config space which is
> wrong.  This was needed for pre-release hardware, and was not removed from
> the driver.  Also, we need to clear the WUS (wake up status) after we
> resume.  Otherwise we can't wake for the same event again since it's still
> asserted in the hardware.  Plus, the multicast lists were being written
> improperly, causing multicast WoL to fail.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
