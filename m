From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: pull request: sfc-next 2012-07-17
Date: Wed, 18 Jul 2012 17:19:54 +0100
Message-ID: <1342628394.2617.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120718.091010.2180226373071597034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51786 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753850Ab2GRQUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:20:00 -0400
In-Reply-To: <20120718.091010.2180226373071597034.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 09:10 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 17 Jul 2012 18:05:40 +0100
> 
> > The following changes since commit 141e369de698f2e17bf716b83fcc647ddcb2220c:
> > 
> >   xfrm: Initialize the struct xfrm_dst behind the dst_enty field (2012-07-14 00:29:12 -0700)
> > 
> > are available in the git repository at:
> >   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
> > 
> > (commit c2dbab39db1c3c2ccbdbb2c6bac6f07cc7a7c1f6)
> > 
> > 1. Fix potential badness when running a self-test with SR-IOV enabled.
> > 2. Fix calculation of some interface statistics that could run backward.
> > 3. Miscellaneous cleanup.
> 
> Looks good, pulled, thanks Ben.
> 
> Out of curiosity, why the conversion to the generic DMA interfaces?
> Do you plan on using something uniquely provided by them vs. the PCI
> specific DMA interfaces (ability to specify GFP flags, stuff like
> that) or do you really plan on having non-PCI devices in the future?

Some DMA operations were already converted because GFP_KERNEL was wanted
or as part of the skb frags API.  I changed the rest to be consistent;
I'm not aware of any plans for non-PCI devices.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
