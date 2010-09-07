From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: (Lack of) specification for RX n-tuple filtering
Date: Tue, 07 Sep 2010 15:43:57 +0100
Message-ID: <1283870637.2270.10.camel@achroite.uk.solarflarecom.com>
References: <1279832544.2104.63.camel@achroite.uk.solarflarecom.com>
	 <4C48BD1A.4060409@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41679 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081Ab0IGOoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 10:44:00 -0400
In-Reply-To: <4C48BD1A.4060409@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-22 at 14:50 -0700, Dimitris Michailidis wrote:
> Ben Hutchings wrote:
> > The n-tuple filtering facility is half-baked at present.  There is an
> > interface to add filters but none to remove them!  And ETHTOOL_GRXNTUPLE
> > is not at all symmetric with ETHTOOL_SRXNTUPLE (which I complained about
> > at the time it was added, to no avail).
> 
> It's a bit worse than that.  Currently one can only append filters, not 
> insert at a given position, as ethtool_rx_ntuple doesn't have an index 
> field.  For devices that use TCAMs, where position matters, it's quite an 
> obstacle.  It also means one cannot modify an existing filter by specifying 
> a new filter for the same index.

It looks like drivers for devices that use TCAMs should implement the
RXNFC interface instead.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

