From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: tg3 and Broadcom PHY driver
Date: Tue, 29 Sep 2009 01:53:59 +0100
Message-ID: <1254185639.27790.3.camel@localhost>
References: <4AC1223B.8070903@embedded-sol.com>
	 <20090928.141527.193009676.davem@davemloft.net>
	 <4AC13036.8030506@embedded-sol.com>
	 <20090928.145522.151077608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: felix@embedded-sol.com, mcarlson@broadcom.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26475 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689AbZI2AyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 20:54:04 -0400
In-Reply-To: <20090928.145522.151077608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-09-28 at 14:55 -0700, David Miller wrote:
> From: Felix Radensky <felix@embedded-sol.com>
> Date: Mon, 28 Sep 2009 23:52:54 +0200
> 
> > Yes, moving CONFIG_TIGON3 right after CONFIG_PHYLIB in
> > drivers/net/Makefile fixes the problem for me.
> 
> Thanks for testing.
> 
> We really need to fix this generically.
> 
> Does anyone think that moving the MDIO/MII/PHY layer objects
> to the top of drivers/net/Makefile will break anything?
> 
> If not, that's what we should do I think.

Only the phylib drivers actually need to be moved to fix the
initialisation order, but moving the others shouldn't hurt.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

