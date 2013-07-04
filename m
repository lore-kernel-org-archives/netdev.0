From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PHC device sharing between PCI functions
Date: Thu, 4 Jul 2013 19:19:05 +0100
Message-ID: <1372961945.1853.9.camel@bwh-desktop.uk.level5networks.com>
References: <1372697768.2083.21.camel@bwh-desktop.uk.level5networks.com>
	 <20130702142420.GC14630@netboy>
	 <1372778262.1919.12.camel@bwh-desktop.uk.level5networks.com>
	 <20130703183035.GA4446@netboy>
	 <1372881153.1919.49.camel@bwh-desktop.uk.level5networks.com>
	 <20130704053605.GC4457@netboy>
	 <1372948466.1853.1.camel@bwh-desktop.uk.level5networks.com>
	 <20130704155339.GA15214@netboy>
	 <1372954878.1853.6.camel@bwh-desktop.uk.level5networks.com>
	 <20130704173925.GA4429@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Laurence Evans <levans@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:44391 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756855Ab3GDSTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 14:19:10 -0400
In-Reply-To: <20130704173925.GA4429@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-04 at 19:39 +0200, Richard Cochran wrote:
> On Thu, Jul 04, 2013 at 05:21:18PM +0100, Ben Hutchings wrote:
> > 
> > But that is the opposite of what we're talking about.  Say the card has,
> > 16 functions resulting in net devices eth0-eth15, each of which can
> > access the same physical clock.  You said it's OK to have read-only
> > aliases for a clock, so then there might be a writable /dev/ptp0 and
> > read-only /dev/ptp1-ptp15.  What is the proper association between net
> > devices and clock devices?
> 
> But the card doesn't have 16 plugs, or does it?

No, but there can be multiple ports, and multiple functions per port.
All sharing the same clock.

> I understood you to have meant that the card has one physical plug,
> shared between one host and fifteen guests. Or maybe I am total
> confused. No, I am surely confused.
> 
> Anyhow, if a host is multihomed, then ideally all of the interfaces
> share one and the same clock. But, if the only purpose of the multiple
> interfaces in the VM host is to assign them to VM guests, then I guess
> it doesn't matter very much how they appear in the VM host.

The functions that are intended to be assigned to guests will still
appear and may have a driver bound to them in the host before they are
assigned to guests.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
