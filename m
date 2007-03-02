From: "Andy Gospodarek" <gospo@redhat.com>
Subject: Re: Network access fails unless tcpdump is running?
Date: Fri, 2 Mar 2007 15:26:59 -0500
Message-ID: <20070302202658.GA15151@core2.greyhouse.net>
References: <87y7mg4vm7.fsf@corps.glidepath.invalid> <20070301201307.GC3199@gospo.rdu.redhat.com> <87ps7s4rbx.fsf@corps.glidepath.invalid> <20070301212245.GD3199@gospo.rdu.redhat.com> <87hct44ka1.fsf@corps.glidepath.invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marc D Ronell <mronell@alumni.upenn.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965570AbXCBUZc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 15:25:32 -0500
Content-Disposition: inline
In-Reply-To: <87hct44ka1.fsf@corps.glidepath.invalid>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2007 at 06:27:18PM -0500, Marc D Ronell wrote:
> Thats correct. Its the wired interface, eth0 which is having the
> problem.  I have turned the wireless interface, eth2 off with both
> ifconfig and ifdown, and still, the connection to the outside only
> works when tcpdump is running.
> 

Good to know.

> > Can you post the output from `ethtool -i ethX` (where ethX is the wired
> > interface).  I ask because that tells me what version of the b44/ipw3945
> > driver you are using.
> >
> >
> 
> # ethtool -i eth0
> driver: b44
> version: 1.01
> firmware-version:
> bus-info: 0000:03:00.0
> 
> 
> The system was working originally fine, but something changed.
> Perhaps through an Debian aptitude update.

Any chance you can boot back to the old kernel (the one where is was
working) and run and ethtool -i eth0 on that one to see what version of
the driver was used there?  It's hard to know what may have changed
between the 2 versions of the driver since I don't know the starting
point.

It's also hard to know if this is fixed already since you aren't running
the latest upstream kernel.  Downloading, building, and testing the
latest from kernel.org would be a good way to know if this is already
fixed.

