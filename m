From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 net-next 0/8] RX NFC support for hash-based filters
Date: Wed, 4 Jan 2012 21:39:30 +0000
Message-ID: <1325713170.3764.2.camel@bwh-desktop>
References: <1325627819.2832.31.camel@bwh-desktop>
	 <20120104.141111.16071561018650942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:57289 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754203Ab2ADVjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 16:39:36 -0500
In-Reply-To: <20120104.141111.16071561018650942.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-01-04 at 14:11 -0500, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 3 Jan 2012 21:56:59 +0000
> 
> > 1. Fix gianfar's validation of filter rule locations.  In the previous
> >    version of this series, this was a requirement for part 2, but that's
> >    no longer the case.
> > 
> > 2. Extend ethtool RX NFC rules API to support hash-based filter hardware
> >    in which rule locations should be selected by the driver or firmware.
> > 
> > 3. Change the sfc driver to implement this API instead of RX n-tuple.
> > 
> > 4. Remove support for RX n-tuple, now that there are no in-tree
> >    implementations.
> 
> All applied, I had to fix some trailing whitespace errors in patches
> 5 and 6.

Thanks, and sorry about the formatting.  I should try to work out why
git didn't alert me to that earlier...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
