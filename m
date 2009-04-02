From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/9] ixgbe: Fix ethtool output with advertised mode.
Date: Thu, 02 Apr 2009 01:15:16 -0700 (PDT)
Message-ID: <20090402.011516.20796253.davem@davemloft.net>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
	<20090401073302.3749.35697.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com, mallikarjuna.chilakala@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60298
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755298AbZDBIP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:15:28 -0400
In-Reply-To: <20090401073302.3749.35697.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 01 Apr 2009 00:33:02 -0700

> Ethtool tries to get advertised speed from phy.autoneg_advertised.
> However for copper media this wasn't happening until later do to
> an other fix which moved mac.ops.setup_link_speed placement in
> ixgbe_link_config(). This patch will display the default advertised
> speeds if it can't yet get this information from phy.autoneg_advertised.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
