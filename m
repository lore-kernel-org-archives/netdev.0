From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] [RFC] New driver "sfc" for Solarstorm SFC4000
	controller
Date: Tue, 27 Nov 2007 22:47:54 -0800
Message-ID: <1196232474.31590.75.camel@localhost>
References: <20071123170815.GH31093@solarflare.com>
	 <20071127220954.4f075056@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Andy Whitcroft <apw@shadowen.org>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Joel Schopp <jschopp@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3441 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754AbXK1GxE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 01:53:04 -0500
In-Reply-To: <20071127220954.4f075056@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-11-27 at 22:09 -0800, Stephen Hemminger wrote:
> ERROR: Macros with multiple statements should be enclosed in a do - while loop
> #21846: FILE: drivers/net/sfc/net_driver.h:1096:
> +	for (_channel = &_efx->channel[0];				\
> +	     _channel < &_efx->channel[EFX_MAX_CHANNELS];		\
> +	     _channel++)						\

This should probably be a WARNING in checkpatch.
Any list_for_each style macro fails this test.


