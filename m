From: Greg KH <gregkh@suse.de>
Subject: Re: Linux 2.6.26.4
Date: Mon, 8 Sep 2008 08:21:14 -0700
Message-ID: <20080908152114.GA8941@suse.de>
References: <20080908143625.GC7311@suse.de> <20080908081253.d3100d88.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org, stable@kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51625 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752529AbYIHPVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 11:21:51 -0400
Content-Disposition: inline
In-Reply-To: <20080908081253.d3100d88.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 08:12:53AM -0700, Randy Dunlap wrote:
> On Mon, 8 Sep 2008 07:36:25 -0700 Greg KH wrote:
> 
> > We (the -stable team) are announcing the release of the 2.6.26.4
> > kernel.
> > 
> > It contains lots of bugfixes, all over the map.  Any users of the 2.6.26
> > kernel series should upgrade to this version.  For details on the fixes,
> > see the changelog entries and the diffstat below.
> > 
> > I'll also be replying to this message with a copy of the patch between
> > 2.6.26.3 and 2.6.26.4
> > 
> > The updated 2.6.26.y git tree can be found at:
> >         git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-2.6.26.y.git
> > and can be browsed at the normal kernel.org git web browser:
> >         http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.26.y.git;a=summary
> 
> >  include/linux/pim.h                |   45 -----------------
> 
> That file is still used by ./net/ipv6/ip6mr.c:#include <linux/pim.h>
> so there are build errors...

Crap, I messed up, David sent me the fixed patch and I forgot it.

I'll go do a new release in a few hours...

thanks,

greg k-h
