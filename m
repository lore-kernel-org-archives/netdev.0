From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/2] caif_usb: Make the driver name check more
 efficient
Date: Sun, 9 Dec 2012 12:07:12 +0000
Message-ID: <1355054832.20838.71.camel@deadeye.wl.decadent.org.uk>
References: <1354897227.2707.10.camel@bwh-desktop.uk.solarflarecom.com>
	 <20121209.003454.640487870743353259.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <sjur.brandeland@stericsson.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35675 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755705Ab2LIMHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 07:07:18 -0500
In-Reply-To: <20121209.003454.640487870743353259.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-12-09 at 00:34 -0500, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 7 Dec 2012 16:20:27 +0000
> 
> > Use the device model to get just the name, rather than using the
> > ethtool API to get all driver information.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> > Compile-tested only.  I'm assuming that the strncmp() is not really
> > necessary, but perhaps there is some OOT variant of cdc_ncm that is also
> > supposed to be supported?
> 
> Applied, I guess you found this while looking around for tests
> of ethtool_ops being NULL?

Yes.  These (bonding and caif_usb) weren't the only ones, though.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
