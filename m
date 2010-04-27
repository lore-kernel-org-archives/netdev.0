From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: Power down PHY during driver resets
Date: Tue, 27 Apr 2010 10:18:49 -0700 (PDT)
Message-ID: <20100427.101849.91330635.davem@davemloft.net>
References: <20100427103814.23338.47637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754221Ab0D0RSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 13:18:43 -0400
In-Reply-To: <20100427103814.23338.47637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 03:38:15 -0700

> From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> The PHY laser is still on during driver init.  It's allowing
> garbage to hit our FIFO, which eventually can cause the entire
> device to die.  Power down the laser while setting up the device,
> and re-enable the laser before getting link.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
