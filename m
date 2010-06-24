From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 2/5] sfc: Implement message level control
Date: Thu, 24 Jun 2010 04:12:18 +0100
Message-ID: <1277349138.26161.144.camel@localhost>
References: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
	 <1277328607.2101.9.camel@achroite.uk.solarflarecom.com>
	 <20100623.182920.28799851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34643 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753483Ab0FXDMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 23:12:22 -0400
In-Reply-To: <20100623.182920.28799851.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-23 at 18:29 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 23 Jun 2010 22:30:07 +0100
> 
> > @@ -850,6 +866,8 @@ const struct ethtool_ops efx_ethtool_ops = {
> >  	.get_drvinfo		= efx_ethtool_get_drvinfo,
> >  	.get_regs_len		= efx_ethtool_get_regs_len,
> >  	.get_regs		= efx_ethtool_get_regs,
> > +	.get_msglevel		= efx_ethtool_get_msglevel,
> > +	.set_msglevel		= efx_ethtool_set_msglevel,
> >  	.nway_reset		= efx_ethtool_nway_reset,
> >  	.get_link		= efx_ethtool_get_link,
> >  	.get_eeprom_len		= efx_ethtool_get_eeprom_len,
> 
> davem@sunset:~/src/GIT/net-next-2.6$ egrep get_regs_len drivers/net/sfc/ethtool.c
> davem@sunset:~/src/GIT/net-next-2.6$ 
> 
> I don't know what tree you're patching this against, but neither net-2.6 nor
> net-next-2.6 have the context you have here in your patch so these patches
> do not apply at all.

I'm hoping you're going to apply
<http://patchwork.ozlabs.org/patch/56308> first.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

