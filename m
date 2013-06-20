From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] net: Add missing dependencies on
 NETDEVICES
Date: Wed, 19 Jun 2013 22:23:56 -0700 (PDT)
Message-ID: <20130619.222356.1963071810938415185.davem@davemloft.net>
References: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk>
	<1371523025.3495.68.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-cris-kernel@axis.com, chad@dahc.us,
	puff65537@bansheeslibrary.com, devel@driverdev.osuosl.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49461 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917Ab3FTFX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 01:23:57 -0400
In-Reply-To: <1371523025.3495.68.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 18 Jun 2013 03:37:05 +0100

> ETRAX_ETHERNET selects ETHERNET and MII, which depend on NETDEVICES.
> I don't think anything should select NETDEVICES, so make it a
> dependency.  It also doesn't need to select or depend on ETHERNET,
> which has nothing to do with the Ethernet library functions.
> 
> BPCTL selects MII, which depends on NETDEVICES.  But everything in the
> drivers/staging/silicom directory is related to net devices, so make
> NET_VENDOR_SILICOM depend on NETDEVICES and remove the now-redundant
> dependencies on NET.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied.
