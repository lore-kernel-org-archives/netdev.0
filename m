From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 1/2] mdio: Export mdio.h to userland
Date: Thu, 01 Mar 2012 16:42:01 -0500 (EST)
Message-ID: <20120301.164201.1555510327922425749.davem@davemloft.net>
References: <1330561407.5881.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47260 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965106Ab2CAVmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 16:42:06 -0500
In-Reply-To: <1330561407.5881.13.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 1 Mar 2012 00:23:27 +0000

> The ID packing definitions are needed by userland and the register
> definitions may also be useful there.
> 
> Do not export mdio_phy_id_{is_c45,prtad,devad}() as the use of bool is
> problematic and it's not that useful to export only a subset of these.
> 
> Do not export MDIO_SUPPORTS_{C22,C45} directly; these flags are only
> exposed to userland through struct ethtool_cmd so they should be
> defined alongside that with appropriate names.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, although I had to fixup trailing whitespace:

> +#ifdef __KERNEL__ 

here.
