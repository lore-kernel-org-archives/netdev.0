From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] mdio: Check MDIO_STAT1_FAULT in mdio45_links_ok()
Date: Wed, 26 Aug 2009 18:04:09 -0700 (PDT)
Message-ID: <20090826.180409.73030827.davem@davemloft.net>
References: <1251310618.27345.13.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53160
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754435AbZH0BD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 21:03:56 -0400
In-Reply-To: <1251310618.27345.13.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 26 Aug 2009 19:16:58 +0100

> Some PHYs will report that the link is up even though there is a fault
> condition.  Therefore, check the fault flag too.  We must also read
> STAT2 to reset this flag.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
