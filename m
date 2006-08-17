From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: proposal for new wireless configuration API
Date: Fri, 18 Aug 2006 01:29:41 +0200
Message-ID: <20060817232941.GB23163@p15091797.pureserver.info>
References: <1155655728.17742.30.camel@ux156> <1155659387.3005.15.camel@localhost.localdomain> <200608151838.58182.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:24315 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1030367AbWHQX3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 19:29:43 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <200608151838.58182.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-08-15 18:38 Michael Buesch wrote:

> On Tuesday 15 August 2006 18:29, Dan Williams wrote:
> > o Separate attributes for channel and frequency
> 
> No, channel and freq is the same. It's just another name
> for the same child. I would say we only want to deal with channel numbers
> in the API. That's much easier, as we don't have to deal with this
> fixed-point (or even floating point) mess. Look at WE for the
> fixed-point mess.
> The userspace tools can easily convert freq to channel and back.
> And in the kernel, we can easily provide some small function
> to convert from channel to khz and back, for example. But I would
> like to see the fixed-point stuff in the API vanish.
> 
> > o Method of finding out channel <-> frequency mapping (not all drivers
> > support this in the SIOCGIWRANGE handler now)
> 
> Yes, that would be a good idea.
> Comes next to the conversion function (see above).

Channel to frequency mapping is defined by 802.11. So we could get
rid of frequencies totally in the user interface and it will also
help with compliance to regulatory rules. Or are here people, who
really want to freely transmit on all frequencies their RF might
be able to generate?

-- 
Uli Kunitz
