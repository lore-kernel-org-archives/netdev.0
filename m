From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] ixgbe: disable tx engine before disabling
 tx laser
Date: Tue, 29 Jun 2010 23:15:13 -0700 (PDT)
Message-ID: <20100629.231513.176662990.davem@davemloft.net>
References: <20100630042739.8925.24962.stgit@localhost.localdomain>
	<20100630042836.8925.82492.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	john.r.fastabend@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59133
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752339Ab0F3GPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 02:15:00 -0400
In-Reply-To: <20100630042836.8925.82492.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 29 Jun 2010 21:28:36 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Disabling the tx laser while receiving DMA requests
> can hang the device.  After this occurs the device
> is in a bad state. The GPIO bit never clears when
> PCI master access is disabled and a reboot is required
> to get the device in a good state again.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
