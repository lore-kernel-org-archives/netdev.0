From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/33] sfc: Change SPI lengths to type size_t
Date: Fri, 12 Dec 2008 21:53:24 -0800 (PST)
Message-ID: <20081212.215324.196962741.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212124851.GB10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44222
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752672AbYLMFxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:53:23 -0500
In-Reply-To: <20081212124851.GB10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:48:51 +0000

> Based on a patch by Andrew Morton.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Sigh, this isn't what you actually build tested, that's
for sure:

drivers/net/sfc/falcon.c:1664: error: conflicting types for 'falcon_spi_cmd'
drivers/net/sfc/spi.h:71: error: previous declaration of 'falcon_spi_cmd' was here

I'll fix it up this time, but never will I do this again.

Test what you send me.
