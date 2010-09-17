From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] ethtool, ixgbe: Move RX n-tuple mask
 fixup to ethtool
Date: Fri, 17 Sep 2010 16:53:41 -0700 (PDT)
Message-ID: <20100917.165341.140752835.davem@davemloft.net>
References: <1284672488.2283.33.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55532
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751752Ab0IQXxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 19:53:23 -0400
In-Reply-To: <1284672488.2283.33.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 16 Sep 2010 22:28:07 +0100

> The ethtool utility does not set masks for flow parameters that are
> not specified, so if both value and mask are 0 then this must be
> treated as equivalent to a mask with all bits set.  Currently that is
> done in the only driver that implements RX n-tuple filtering, ixgbe.
> Move it to the ethtool core.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Looks good to me, applied, thanks Ben.
