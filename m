From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 RFC PATCH] e1000e: NUMA changes, add Node=
 parameter
Date: Thu, 23 Sep 2010 18:17:24 +0100
Message-ID: <1285262244.7794.11.camel@achroite.uk.solarflarecom.com>
References: <20100923032534.11274.77976.stgit@localhost.localdomain>
	 <20100922.203642.02274207.davem@davemloft.net>
	 <alpine.WNT.2.00.1009230932300.5948@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>,
	shemminger@linux-foundation.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:32892 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600Ab0IWRR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 13:17:28 -0400
In-Reply-To: <alpine.WNT.2.00.1009230932300.5948@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-09-23 at 09:46 -0700, Brandeburg, Jesse wrote:
> 
> On Wed, 22 Sep 2010, David Miller wrote:
> 
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date: Wed, 22 Sep 2010 20:28:10 -0700
> > 
> > > Although a module parameter is not the preferred way for
> > > in-tree modules, this problem is not solvable in ethtool without
> > > mod params because of needing the information at probe time to
> > > control early allocations of memory.  Ideally there would even be
> > > a way to control the node where the memory of the netdev struct
> > > would be allocated also.
> > 
> > Sorry, no.
> > 
> > Various folks are working on infrastructure such that the Numa node of
> > everything other than the netdev struct can be dynamically choosen.
> > 
> > I'm sure we can find a way to dynamically reallocate and re-attach the
> > netdev structure as well.
> 
> okay, thanks for your comments, we can carry this patch out-of-tree.  
> 
> Unfortunately as I said in the comments there is really no way around this 
> *now* other than some fixed binding scheme, none of which are one size 
> fits all, which is why I (reluctantly) supplied the module parameter 
> patch.
> 
> I'm interested to hear more about the "various folks' infrastructure" 
> plans, I'll do some research.  I can definitely provide testing.
[...]

I think David may be referring to this:

http://article.gmane.org/gmane.linux.network/172386

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

