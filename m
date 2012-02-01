From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ethtool: Null-terminate filename passed to
 ethtool_ops::flash_device
Date: Wed, 01 Feb 2012 14:47:52 -0500 (EST)
Message-ID: <20120201.144752.544117675701129801.davem@davemloft.net>
References: <1328124745.2541.12.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33890 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932285Ab2BATr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 14:47:58 -0500
In-Reply-To: <1328124745.2541.12.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 1 Feb 2012 19:32:25 +0000

> The parameters for ETHTOOL_FLASHDEV include a filename, which ought to
> be null-terminated.  Currently the only driver that implements
> ethtool_ops::flash_device attempts to add a null terminator if
> necessary, but does it wrongly.  Do it in the ethtool core instead.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks Ben.
