From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Fri, 8 Jan 2010 20:22:27 -0500
Message-ID: <20100109012227.GA2762@localhost.localdomain>
References: <20100105.163911.10233438.davem@davemloft.net>
 <20100108124033.GA28782@hmsreliant.think-freely.org>
 <20100108.132107.38069748.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60816 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538Ab0AIBWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 20:22:35 -0500
Content-Disposition: inline
In-Reply-To: <20100108.132107.38069748.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 08, 2010 at 01:21:07PM -0800, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Fri, 8 Jan 2010 07:40:33 -0500
> 
> > Dave, sorry about this, but it looks like we can scrap this, I just
> > looked at the initial tcpdump this was reported in, and apparently
> > w2k doesn't compute the checksum properly on these old style
> > keepalives.
> 
> Thanks for the update.  Nothing to be sorry about, this is actually a
> relief and we learned a lot about keepalives and zero-window probes in
> the process :-)
> 

I'm trying to do some independent computation on it, but its looking like this
may have been a combination of old software (win2k) and a bad corner case in
hardware.  I think the reporter has a NIC that doesn't do TCO properly on these
old style keepalives, which would explain why it wasn't reproducable outside of
the reporters environment.  I'm trying to figure out which card/hw revision of
NIC they were using.  It might be worth coding an errata check into the
appropriate driver if this all turns out to be accurate to disable TCO affectecd
hw.

Neil

