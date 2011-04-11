From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] gianfar: Clean up implementation of
 RX network flow classification
Date: Mon, 11 Apr 2011 13:29:09 -0700 (PDT)
Message-ID: <20110411.132909.232734437.davem@davemloft.net>
References: <1302306311.2871.56.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54604
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753167Ab1DKU3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:29:45 -0400
In-Reply-To: <1302306311.2871.56.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sat, 09 Apr 2011 00:45:11 +0100

> This code was cribbed from niu, so gfar_set_hash_opts() begins by
> converting the ethtool flow class code into a class code for Sun
> Neptune hardware, then does the same thing again for the hardware it's
> really dealing with.  It may also return -1 (-EPERM) for some
> unhandled ethtool flow class codes.
> 
> Remove the useless code and definitions, and fix the error code.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This isn't even compile-tested, since it can only be built for some
> PowerPC SoCs.  Could someone on ppc-dev check that this won't break the
> driver?

I'm applying this, it looks so trivial to me that I'm willing to take
the build risk :-)

Thanks.
