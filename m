From: David Miller <davem@davemloft.net>
Subject: Re: TCP event tracking via netlink...
Date: Wed, 05 Dec 2007 21:03:43 -0800 (PST)
Message-ID: <20071205.210343.57693750.davem@davemloft.net>
References: <20071205.053031.87154402.davem@davemloft.net>
	<4756B175.5010108@psc.edu>
	<20071205144843.GB2623@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58929
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750778AbXLFFDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 00:03:44 -0500
In-Reply-To: <20071205144843.GB2623@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 5 Dec 2007 17:48:43 +0300

> On Wed, Dec 05, 2007 at 09:11:01AM -0500, John Heffner (jheffner@psc.edu) wrote:
> > >Maybe if we want to get really fancy we can have some more-expensive
> > >debug mode where detailed specific events get generated via some
> > >macros we can scatter all over the place.  This won't be useful
> > >for general user problem analysis, but it will be excellent for
> > >developers.
> > >
> > >Let me know if you think this is useful enough and I'll work on
> > >an implementation we can start playing with.
> > 
> > 
> > FWIW, sounds similar to what these guys are doing with SIFTR for FreeBSD:
> > http://caia.swin.edu.au/urp/newtcp/tools.html
> > http://caia.swin.edu.au/reports/070824A/CAIA-TR-070824A.pdf
> 
> And even more similar to this patch from Samir Bellabes of Mandriva:
> http://lwn.net/Articles/202255/

I think this work is very different.

When I say "state" I mean something more significant than
CLOSE, ESTABLISHED, etc. which is what Samir's patches are
tracking.

I'm talking about all of the sequence numbers, SACK information,
congestion control knobs, etc. whose values are nearly impossible to
track on a packet to packet basis in order to diagnose problems.

Web100 provided facilities along these lines as well.
