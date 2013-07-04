From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PHC device sharing between PCI functions
Date: Thu, 4 Jul 2013 15:34:26 +0100
Message-ID: <1372948466.1853.1.camel@bwh-desktop.uk.level5networks.com>
References: <1372697768.2083.21.camel@bwh-desktop.uk.level5networks.com>
	 <20130702142420.GC14630@netboy>
	 <1372778262.1919.12.camel@bwh-desktop.uk.level5networks.com>
	 <20130703183035.GA4446@netboy>
	 <1372881153.1919.49.camel@bwh-desktop.uk.level5networks.com>
	 <20130704053605.GC4457@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Laurence Evans <levans@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:18607 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756715Ab3GDOea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 10:34:30 -0400
In-Reply-To: <20130704053605.GC4457@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-04 at 07:36 +0200, Richard Cochran wrote:
> On Wed, Jul 03, 2013 at 08:52:33PM +0100, Ben Hutchings wrote:
> > 
> > So you think each function should have its own clock device, but it's
> > only writable on one?  I think that would work, but I thought it would
> > be undesirable to have multiple aliases for the same physical clock.
> 
> The aliases would not bother me, as long as the ethtool interface-to-phc
> association works properly.

Well what would be 'properly' in this case?

> Of course, if there is a way to suppress
> the aliases in the non-VM case, that would be ideal.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
