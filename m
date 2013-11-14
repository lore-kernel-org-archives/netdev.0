From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC][PATCH 0/3] net_tstamp: Add SIOCGHWTSTAMP ioctl
Date: Thu, 14 Nov 2013 15:10:19 +0000
Message-ID: <1384441819.2771.0.camel@deadeye.wl.decadent.org.uk>
References: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
	 <20131114074118.GC4908@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7635 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755Ab3KNPK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 10:10:26 -0500
In-Reply-To: <20131114074118.GC4908@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 08:41 +0100, Richard Cochran wrote:
> On Thu, Nov 14, 2013 at 02:37:15AM +0000, Ben Hutchings wrote:
> > SIOCSHWTSTAMP returns the real configuration to the application
> > using it, but there is currently no way for any other
> > application to find out the configuration non-destructively.
> 
> I guess that the reasoning behind the original interface is that an
> application only wants to know the settings when it needs a particular
> setting in order to operate correctly. This would make the query call
> pointless, since the application might as well just go ahead and set
> the values that it needs.
> 
> Do you have a particular use case in mind?

The immediate motivation is wanting to include this information in
diagnostic reports.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
