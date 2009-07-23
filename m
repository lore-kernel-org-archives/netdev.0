From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] ixgbe: Enable FCoE offload when DCB is
 enabled for 82599
Date: Thu, 23 Jul 2009 11:06:07 -0700 (PDT)
Message-ID: <20090723.110607.28145569.davem@davemloft.net>
References: <20090723000705.27299.19299.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59478
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751379AbZGWSGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 14:06:02 -0400
In-Reply-To: <20090723000705.27299.19299.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Jul 2009 17:07:12 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> Currently, FCoE offload feature is turned on when the kernel config has
> CONFIG_FCOE or CONFIG_FCOE_MODULE set. However, we really want to turn
> FCoE offload on when there is FCoE traffic passing and turn it off when
> it's just LAN traffic. Since FCoE depends on a lossless network provided
> by DCB, this allows us to have FCoE turned on/off when user turns on DCB
> using dcbtool.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
