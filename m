From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] ixgbe: fix slow load times on 82598 nics
Date: Mon, 26 Jan 2009 20:57:26 -0800 (PST)
Message-ID: <20090126.205726.187504211.davem@davemloft.net>
References: <20090123083733.20920.86146.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40328
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751846AbZA0E53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 23:57:29 -0500
In-Reply-To: <20090123083733.20920.86146.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 23 Jan 2009 00:37:33 -0800

> Load times for NICs that use i2c to communicate with the phy were taking
> ~4.5 sec per port.  This fix first checks to see if the link is already
> up before calling get_link_capabilities, since if it is we don't need
> query the phy for link state.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
