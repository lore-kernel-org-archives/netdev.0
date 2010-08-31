From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [rfc] Merging the Open vSwitch datapath
Date: Mon, 30 Aug 2010 17:54:10 -0700
Message-ID: <20100831005410.GB30129@sequoia.sous-sol.org>
References: <20100830062755.GA22396@verge.net.au>
 <87k4n8ow1r.fsf@benpfaff.org>
 <43F901BD926A4E43B106BF17856F0755F63A08EE@orsmsx508.amr.corp.intel.com>
 <20100830183328.GI7629@nicira.com>
 <43F901BD926A4E43B106BF17856F0755F63A092B@orsmsx508.amr.corp.intel.com>
 <20100830205907.GM30129@sequoia.sous-sol.org>
 <20100831004827.GE11594@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ben Pfaff <blp@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:52138 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756385Ab0HaAz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 20:55:27 -0400
Content-Disposition: inline
In-Reply-To: <20100831004827.GE11594@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Simon Horman (horms@verge.net.au) wrote:
> On Mon, Aug 30, 2010 at 01:59:07PM -0700, Chris Wright wrote:
> > * Rose, Gregory V (gregory.v.rose@intel.com) wrote:
> > > >From: Ben Pfaff [mailto:blp@nicira.com]
> > > >On Mon, Aug 30, 2010 at 11:26:17AM -0700, Rose, Gregory V wrote:
> > > >> I just want to put in a plug for the netlink interface.  For NICs with
> > > >> EVB we'll need it.
> > > >
> > > >Off-hand, the main reasons to use Netlink, instead of the existing
> > > >character device interface, are that Netlink is easier to extend and
> > > >that it should reduce or eliminate the 32-to-64 bit compat layer
> > > >currently in the Open vSwitch tree.
> > 
> > That, plus it's a typical way to do network configuration.  Esp. with
> > bi-directional communication.  So the userspace bit both listens to
> > netlink messages, like any of the routing daemons or lldpad or similar
> > do, and sends netlink messasges to update driver's flow table.
> > 
> > BTW, this kind of discussion was why Herbert felt strongly against
> > drivers/staging/.  He wanted to be sure the interfaces were well-defined
> > first.
> 
> Is the implication that there is a preference for finalising
> the interface (as much as that is possible) before merging?

I'll let Herbert chime in, just reminder that was his thought earlier
this month at LinuxCon.

thanks,
-chris
