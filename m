From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 1/2] net: Enable 64-bit net device statistics on
 32-bit architectures
Date: Tue, 08 Jun 2010 16:56:50 +0100
Message-ID: <1276012610.2185.2.camel@achroite.uk.solarflarecom.com>
References: <1275689093.2095.36.camel@achroite.uk.solarflarecom.com>
	 <20100607.211829.63035366.davem@davemloft.net>
	 <1275996928.14011.83.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, arnd@arndb.de, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31396 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752971Ab0FHP4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 11:56:54 -0400
In-Reply-To: <1275996928.14011.83.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-08 at 12:35 +0100, Ben Hutchings wrote:
[...]
> > And the whole tree needs to be inspected to make sure there isn't going
> > to be fallout in areas your patch didn't take care of wrt. printf format
> > strings and the like.
> > 
> > What was always "unsigned long" is now a variable type, therefore using
> > a fixed printf format string is impossible unless you always cast these
> > things when passed in as printf arguments.
> 
> Yes, that's true if there are drivers out there printing members of
> net_device_stats.  I admit I haven't checked for that.  (Hmm, might be
> time to try Coccinelle.)

There are a few of those, so I'll keep the declared type as unsigned
long rather than making the sizes explicit.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

