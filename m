From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mdio: Export mdio.h to userland
Date: Wed, 29 Feb 2012 18:31:33 -0500 (EST)
Message-ID: <20120229.183133.1451263231661298778.davem@davemloft.net>
References: <1330555428.5881.8.camel@bwh-desktop>
	<20120229.180242.197576747542301377.davem@davemloft.net>
	<1330556992.5881.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756760Ab2B2Xbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:31:40 -0500
In-Reply-To: <1330556992.5881.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 29 Feb 2012 23:09:52 +0000

> I could just move the mdio_phy_id_is_c45(), mdio_phy_id_prtad(),
> mdio_phy_id_devad() functions inside #ifdef __KERNEL__ since userland
> shouldn't need to unpack PHY IDs.

That would work too.
