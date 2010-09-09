From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] ethtool: Complete kernel-doc comments for
 RX flow filter and hash control
Date: Thu, 09 Sep 2010 14:52:33 +0100
Message-ID: <1284040353.2250.0.camel@achroite.uk.solarflarecom.com>
References: <1283870488.2270.9.camel@achroite.uk.solarflarecom.com>
	 <1283870780.2270.12.camel@achroite.uk.solarflarecom.com>
	 <20100908.140512.242117688.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: santwona.behera@sun.com, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	dm@chelsio.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:44431 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753786Ab0IINwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 09:52:37 -0400
In-Reply-To: <20100908.140512.242117688.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-09-08 at 14:05 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 07 Sep 2010 15:46:20 +0100
> 
> > On Tue, 2010-09-07 at 15:41 +0100, Ben Hutchings wrote:
> >> There are now several interfaces within the ethtool API for getting
> >> and setting RX flow filtering and hashing behaviour, most of which are
> >> poorly documented.  This adds kernel-doc comments for all these
> >> interfaces, based on the existing incomplete comments and on the
> >> initial implementations.
> >> 
> >> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> >> ---
> >> Santwona, Peter,
> >> 
> >> Please point out any errors and any information that should be added to
> >> the comments to explain the significant differences between the RXNFC
> >> and RXNTUPLE interfaces.
> > [...]
> >> +/**
> >> + * struct ethtool_rx_ntuple - command to get or set RX flow filter
> >> + * @cmd: Specific command number - %ETHTOOL_GRXNTUPLE or %ETHTOOL_SRXNTUPLE
> > 
> > Of course this is wrong - ETHTOOL_GRXNTUPLE uses struct ethtool_gstrings
> > instead.
> 
> Ben, please submit a fixed up version of the patch.

Will do, but I'm still waiting for feedback from Santwona and Peter.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

