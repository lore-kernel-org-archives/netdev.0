From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [GIT]: Networking
Date: Fri, 5 Sep 2008 14:17:04 -0400
Message-ID: <20080905181704.GC3027@tuxdriver.com>
References: <20080827.164649.87042354.davem@davemloft.net> <1220627292.7260.3.camel@2710p.home> <alpine.LFD.1.10.0809051039070.3117@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Williamson <alex.williamson@hp.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jouni.malinen@atheros.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50796 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbYIESaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 14:30:30 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0809051039070.3117@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 05, 2008 at 10:45:11AM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 5 Sep 2008, Alex Williamson wrote:
> 
> > On Wed, 2008-08-27 at 16:46 -0700, David Miller wrote:
> > 
> > > 22) Two mac80211 bug fixes from Jouni Malinen:
> > >     a) Use IWEVCUSTOM so that we don't hit the 256 byte limit that
> > >        IWEVASSOCREQIE has
> > 
> > This one breaks wireless with 32bit userspace/64bit kernel.  Bisected
> > back to changeset 087d833e5a9f67ba933cb32eaf5a2279c1a5b47c:
> > 
> > mac80211: Use IWEVASSOCREQIE instead of IWEVCUSTOM
> 
> Grr. I'd love to say "I told you so", and write another rant about -rc 
> series patches. But I'm too lazy, so people - please mentally insert my 
> standard rant here.
> 
> David/Jouni - just revert it?

Yes, just revert it.

Jouni, feel free to send me a new version for 2.6.28.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
