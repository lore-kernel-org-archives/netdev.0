From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Wed, 1 Nov 2006 09:20:28 -0500
Message-ID: <20061101142022.GC21668@tuxdriver.com>
References: <20061026050416.GB14199@havoc.gtf.org> <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net> <20061101112805.246e1b3b@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:8718 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1946900AbWKAOW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 09:22:56 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20061101112805.246e1b3b@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 01, 2006 at 11:28:05AM +0100, Jiri Benc wrote:
> On Wed, 25 Oct 2006 22:15:23 -0700, Simon Barber wrote:
> > Re: registering as a real protocol - yes this I have been going on about
> > for a while. This needs a few changes in how things work:
> > 
> > 1. Register as a real protocol.
> > 2. Change drivers to use netif_rx to receive frames (will also be more
> > efficient)
> 
> This is something I really want too.

I see Simon's suggestions in the category of making wireless devices
"1st class citizens".  I mostly agree with his suggestions, and they
are "on my list".  Do we see these as merge requirements?  I have them
as a lower priority than locking analysis/fixes, cfg80211 migration,
fullmac support, and driver porting.

Is this agreeable?  Or do we think this needs to happen before a
merge to -mm?

John
-- 
John W. Linville
linville@tuxdriver.com
