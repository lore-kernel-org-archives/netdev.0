From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PHC device sharing between PCI functions
Date: Thu, 4 Jul 2013 17:21:18 +0100
Message-ID: <1372954878.1853.6.camel@bwh-desktop.uk.level5networks.com>
References: <1372697768.2083.21.camel@bwh-desktop.uk.level5networks.com>
	 <20130702142420.GC14630@netboy>
	 <1372778262.1919.12.camel@bwh-desktop.uk.level5networks.com>
	 <20130703183035.GA4446@netboy>
	 <1372881153.1919.49.camel@bwh-desktop.uk.level5networks.com>
	 <20130704053605.GC4457@netboy>
	 <1372948466.1853.1.camel@bwh-desktop.uk.level5networks.com>
	 <20130704155339.GA15214@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Laurence Evans <levans@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28965 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756525Ab3GDQVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 12:21:22 -0400
In-Reply-To: <20130704155339.GA15214@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-04 at 17:53 +0200, Richard Cochran wrote:
> On Thu, Jul 04, 2013 at 03:34:26PM +0100, Ben Hutchings wrote:
> > On Thu, 2013-07-04 at 07:36 +0200, Richard Cochran wrote:
> > > 
> > > The aliases would not bother me, as long as the ethtool interface-to-phc
> > > association works properly.
> > 
> > Well what would be 'properly' in this case?
> 
> If a PCIe card provides one interface eth0 and four PHC devcies
> /dev/ptp0-3, then doing 'ethtool -T eth0' should show PHC index 0.

But that is the opposite of what we're talking about.  Say the card has,
16 functions resulting in net devices eth0-eth15, each of which can
access the same physical clock.  You said it's OK to have read-only
aliases for a clock, so then there might be a writable /dev/ptp0 and
read-only /dev/ptp1-ptp15.  What is the proper association between net
devices and clock devices?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
