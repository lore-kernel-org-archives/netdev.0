From: David Miller <davem@davemloft.net>
Subject: Re: Linux 2.6.26.4
Date: Mon, 08 Sep 2008 12:33:19 -0700 (PDT)
Message-ID: <20080908.123319.141509323.davem@davemloft.net>
References: <20080908152114.GA8941@suse.de>
	<20080908163801.GA13827@suse.de>
	<20080908095608.4dae8a2e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, stable@kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36371
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752999AbYIHTd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 15:33:26 -0400
In-Reply-To: <20080908095608.4dae8a2e.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 8 Sep 2008 09:56:08 -0700

> On Mon, 8 Sep 2008 09:38:01 -0700 Greg KH wrote:
> 
> > On Mon, Sep 08, 2008 at 08:21:14AM -0700, Greg KH wrote:
> > > On Mon, Sep 08, 2008 at 08:12:53AM -0700, Randy Dunlap wrote:
> > > > On Mon, 8 Sep 2008 07:36:25 -0700 Greg KH wrote:
> > > > 
> > > > > We (the -stable team) are announcing the release of the 2.6.26.4
> > > > > kernel.
> > > > > 
> > > > > It contains lots of bugfixes, all over the map.  Any users of the 2.6.26
> > > > > kernel series should upgrade to this version.  For details on the fixes,
> > > > > see the changelog entries and the diffstat below.
> > > > > 
> > > > > I'll also be replying to this message with a copy of the patch between
> > > > > 2.6.26.3 and 2.6.26.4
> > > > > 
> > > > > The updated 2.6.26.y git tree can be found at:
> > > > >         git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-2.6.26.y.git
> > > > > and can be browsed at the normal kernel.org git web browser:
> > > > >         http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.26.y.git;a=summary
> > > > 
> > > > >  include/linux/pim.h                |   45 -----------------
> > > > 
> > > > That file is still used by ./net/ipv6/ip6mr.c:#include <linux/pim.h>
> > > > so there are build errors...
> > > 
> > > Crap, I messed up, David sent me the fixed patch and I forgot it.
> > 
> > Randy, does the patch below fix the problem?  It's an interdiff between
> > what I applied and what David sent me as the correct patch.
> 
> Yes, that fixes the build error.  Thanks.

Sorry for creating such a confusing situation Greg :)
