From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ethtool: Add n-tuple string length to
 drvinfo and return it
Date: Fri, 26 Feb 2010 05:11:45 -0800 (PST)
Message-ID: <20100226.051145.01410157.davem@davemloft.net>
References: <20100226115355.20213.59254.stgit@localhost.localdomain>
	<20100226.042027.250812962.davem@davemloft.net>
	<4B87C70F.8060403@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, peter.p.waskiewicz.jr@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58701
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936066Ab0BZNL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 08:11:27 -0500
In-Reply-To: <4B87C70F.8060403@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 26 Feb 2010 08:05:19 -0500

> NAK.  Did you even read the patch?

I did, brain doesn't work sometimes :-)

> We don't increase the size of struct ethtool_drvinfo, _especially_ by
> sticking struct members into the middle of the struct.
> 
> What do you think 'reserved' is for???

Right, I'll revert, thanks.
