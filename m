From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb3: Restore dependency on INET
Date: Wed, 28 Nov 2012 17:41:19 -0500 (EST)
Message-ID: <20121128.174119.1603665513068752517.davem@davemloft.net>
References: <1354132983.2768.1.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com, divy@chelsio.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53602 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756338Ab2K1WlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 17:41:24 -0500
In-Reply-To: <1354132983.2768.1.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Nov 2012 20:03:03 +0000

> Commit ff33c0e1885cda44dd14c79f70df4706f83582a0 ('net: Remove bogus
> dependencies on INET') wrongly removed this dependency.  cxgb3 uses
> the arp_send() function defined in net/ipv4/arp.c.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
