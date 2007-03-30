From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bonding-devel] quick help with bonding?
Date: Thu, 29 Mar 2007 20:36:31 -0400
Message-ID: <20070330003630.GA18319@gospo.rdu.redhat.com>
References: <460BE5F0.7070606@nortel.com> <20070329181617.GA25770@gospo.rdu.redhat.com> <460C38EF.1080509@nortel.com> <4074.1175207458@death> <460C4EFE.6030505@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34367 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934380AbXC3Agh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 20:36:37 -0400
Content-Disposition: inline
In-Reply-To: <460C4EFE.6030505@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 29, 2007 at 05:42:54PM -0600, Chris Friesen wrote:
> Jay Vosburgh wrote:
> 
> > 	2.6.10 is pretty old, and there have been a number of fixes to
> > the bonding ARP monitor since then, so it may be that it is simply
> > misbehaving (presuming that you're running the 2.6.10 bonding driver).
> > Are you in a position to test against a more recent kernel (and/or
> > bonding driver)?  Does the miimon misbehave in a similar fashion?
> 
> Testing a more recent kernel is problematic.  A new bonding driver could 
> be possible, assuming the code hasn't changed too much.

If you are looking for a decent source for patches you could consider
downloading the latest source-rpm from RHEL4/CentOS4.  The bonding
driver in those releases have been updated to much later code and I can
tell you from personal experience they work pretty well.  You may need
to do some backporting to get the latest arp-monitoring features, but
let me know if you need a hand with that, I might have some laying
around. ;)
 
> I just did another experiment.  Normally we boot via eth4 (which then 
> becomes part of the bond  with eth5 at init time).  If I boot via eth6 
> instead, it appears as though the problem doesn't show up.

Does eth6 use the same hardware/driver as eth4/5?  (Sorry if I missed
that in the thread, but didn't see if you indicated that it did.)
