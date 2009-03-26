From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] ixgbe: Allow Priority Flow Control settings
 to survive a device reset
Date: Thu, 26 Mar 2009 01:14:01 -0700 (PDT)
Message-ID: <20090326.011401.204947051.davem@davemloft.net>
References: <20090326081042.30689.93164.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35557
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751173AbZCZIOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:14:14 -0400
In-Reply-To: <20090326081042.30689.93164.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 26 Mar 2009 01:10:42 -0700

> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> When changing DCB parameters, ixgbe needs to have the MAC reset.  The way
> the flow control code is setup today, PFC will be disabled on a reset.
> This patch adds a new flow control type for PFC, and then has the netlink
> layer take care of toggling which type of flow control to enable.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

