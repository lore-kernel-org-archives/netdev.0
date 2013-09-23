From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 11/11] sfc: Add static tracepoints to datapath
Date: Mon, 23 Sep 2013 14:17:23 -0400 (EDT)
Message-ID: <20130923.141723.230027899643613700.davem@davemloft.net>
References: <1379788592.1681.45.camel@bwh-desktop.uk.level5networks.com>
	<20130923.020838.2084214261543483443.davem@davemloft.net>
	<1379951467.2485.33.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877Ab3IWSR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 14:17:27 -0400
In-Reply-To: <1379951467.2485.33.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 23 Sep 2013 16:51:07 +0100

> 2. Generic trace events would be subject to changes that could make them
> unsuitable for Solarflare's tests.

This is not an argument for doing things privately in your driver and
duplicating things.

We should make a facility that's useful to Solarflare _AS WELL AS_
everyone else.

> 4. Static tracepoints always have run-time overhead, so these should
> probably be controlled by a kconfig option (as in this patch).

Don't we use static branches and other tricks to make them close to zero
overhead?
