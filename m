From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-2.6] sfc: 10Xpress: Report support for pause frames
Date: Thu, 22 Oct 2009 23:30:02 +0100
Message-ID: <1256250602.2785.25.camel@achroite>
References: <1256250314.2785.22.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:19776 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbZJVWaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 18:30:01 -0400
In-Reply-To: <1256250314.2785.22.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-10-22 at 23:25 +0100, Ben Hutchings wrote:
> Commits 27fbc7d 'mdio: Expose pause frame advertising flags to ethtool'
> and c634263 'sfc: 10Xpress: Initialise pause advertising flags'
> added to our reported advertising flags.
> 
> efx_mdio_set_settings() requires that all advertising flags are
> also present in the supported flags, so make sure that is true.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This fixes a regression in 2.6.32: after resetting a 10Xpress PHY we
> fail to reconfigure it if pause frames are enabled.  Manually changing
> pause frame settings will also fail.

Sorry, I was mistaken - those earlier commits are only in net-next-2.6,
so this is not needed for 2.6.32.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

