From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 11/11] sfc: Add static tracepoints to datapath
Date: Mon, 23 Sep 2013 02:08:38 -0400 (EDT)
Message-ID: <20130923.020838.2084214261543483443.davem@davemloft.net>
References: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
	<1379788592.1681.45.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816Ab3IWGIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 02:08:41 -0400
In-Reply-To: <1379788592.1681.45.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 21 Sep 2013 19:36:32 +0100

> These tracepoints support the driver-specific datapath feature tests
> we're running internally, though they might be useful for other
> purposes.  The skb fields are chosen to cover driver features
> implemented now or likely to be added soon.
> 
> (Includes a bug fix from Edward Cree.)
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Make this generic, rather than specific to this driver.

You're putting a tracepoint right before calls to the generic core
receive interfaces.  That makes no sense at all.
