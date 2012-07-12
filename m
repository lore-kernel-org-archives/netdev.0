From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 01/11] sfc: Implement 128-bit writes for
 efx_writeo_page
Date: Thu, 12 Jul 2012 17:17:27 +0100
Message-ID: <1342109847.2662.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
	 <1342048518.2613.60.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120712.081300.624240435828585132.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41714 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934039Ab2GLQRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:17:30 -0400
In-Reply-To: <20120712.081300.624240435828585132.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 08:13 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Thu, 12 Jul 2012 00:15:18 +0100
> 
> > Add support for writing a TX descriptor to the NIC in one PCIe
> > transaction on x86_64 machines.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> This absolutely does not belong in a driver.

OK.  My assumption was that 128-bit MMIO on a data path would be so rare
that this would not be generically useful.  (Really long MMIOs are
likely to be done with write-combining, so that the data width of
instructions doesn't matter much.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
