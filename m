From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] ethtool: Define and apply a default
 policy for RX flow hash indirection
Date: Fri, 16 Dec 2011 13:54:02 -0500 (EST)
Message-ID: <20111216.135402.1422705681678794730.davem@davemloft.net>
References: <1323993076.2773.23.camel@bwh-desktop>
	<1323993409.2773.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, mcarlson@broadcom.com,
	eilong@broadcom.com, dm@chelsio.com, sbhatewara@vmware.com,
	netdev@vger.kernel.org, pv-drivers@vmware.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932525Ab1LPSyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:54:08 -0500
In-Reply-To: <1323993409.2773.28.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 15 Dec 2011 23:56:49 +0000

> All drivers that support modification of the RX flow hash indirection
> table initialise it in the same way: RX rings are assigned to table
> entries in rotation.  Make that default policy explicit by having them
> call a ethtool_rxfh_indir_default() function.
> 
> In the ethtool core, add support for a zero size value for
> ETHTOOL_SRXFHINDIR, which resets the table to this default.
> 
> Partly-suggested-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.

> + * @size: On entry, the array size of the user buffer, which may be zero.
> + *	On return from %ETHTOOL_GRXFHINDIR, the array size of the hardware
> + *	indirection table. 
                          ^^^

Trailing whitespace I had to fixup while applying this, just FYI.
