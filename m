From: David Miller <davem@davemloft.net>
Subject: Re: Why is this patch not in 2.6.22-rc5?
Date: Tue, 19 Jun 2007 15:04:37 -0700 (PDT)
Message-ID: <20070619.150437.38693228.davem@davemloft.net>
References: <15712.1181795790@death>
	<20070619082302.4b9a5c27@localhost.localdomain>
	<467817CE.80904@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, fubar@us.ibm.com,
	da-x@monatomic.org, ctindel@users.sourceforge.net,
	kaneshige.kenji@jp.fujitsu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	bonding-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41808
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752465AbXFSWET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 18:04:19 -0400
In-Reply-To: <467817CE.80904@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 19 Jun 2007 13:52:14 -0400

> Stephen Hemminger wrote:
> > On Wed, 13 Jun 2007 21:36:30 -0700
> > Jay Vosburgh <fubar@us.ibm.com> wrote:
> > 
> >> 	The following patch (based on a patch from Stephen Hemminger
> >> <shemminger@linux-foundation.org>) removes use after free conditions in
> >> the unregister path for the bonding master.  Without this patch, an
> >> operation of the form "echo -bond0 > /sys/class/net/bonding_masters"
> >> would trigger a NULL pointer dereference in sysfs.  I was not able to
> >> induce the failure with the non-sysfs code path, but for consistency I
> >> updated that code as well.
> >>
> >> 	I also did some testing of the bonding /proc file being open
> >> while the bond is being deleted, and didn't see any problems there.
> >>
> >> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> > 	
> > Hey David, this patch fixes one of the bugs listed in 2.6.22-rc5
> > list. Jay submitted last week but it hasn't made it upstream.
> 
> Get him to forward it to me, like he does for other bonding patches...

Yes, this patch definitely should go via Jeff, he handles merging the
bonding bits.
