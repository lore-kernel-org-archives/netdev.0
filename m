From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] phylib: Support phy module autoloading
Date: Fri, 02 Apr 2010 14:31:23 -0700 (PDT)
Message-ID: <20100402.143123.230371935.davem@davemloft.net>
References: <20100401.193810.172601735.davem@davemloft.net>
	<1270206327.3101.2436.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58989
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754809Ab0DBVbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 17:31:22 -0400
In-Reply-To: <1270206327.3101.2436.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Fri, 02 Apr 2010 12:05:27 +0100

> We don't use the normal hotplug mechanism because it doesn't work. It will
> load the module some time after the device appears, but that's not good
> enough for us -- we need the driver loaded _immediately_ because otherwise
> the NIC driver may just abort and then the phy 'device' goes away.
> 
> [bwh: s/phy/mdio/ in module alias, kerneldoc for struct mdio_device_id]
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
