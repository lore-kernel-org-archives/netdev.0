From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc] Merging the Open vSwitch datapath
Date: Tue, 31 Aug 2010 09:48:27 +0900
Message-ID: <20100831004827.GE11594@verge.net.au>
References: <20100830062755.GA22396@verge.net.au>
 <87k4n8ow1r.fsf@benpfaff.org>
 <43F901BD926A4E43B106BF17856F0755F63A08EE@orsmsx508.amr.corp.intel.com>
 <20100830183328.GI7629@nicira.com>
 <43F901BD926A4E43B106BF17856F0755F63A092B@orsmsx508.amr.corp.intel.com>
 <20100830205907.GM30129@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ben Pfaff <blp@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58506 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756043Ab0HaAsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 20:48:32 -0400
Content-Disposition: inline
In-Reply-To: <20100830205907.GM30129@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 30, 2010 at 01:59:07PM -0700, Chris Wright wrote:
> * Rose, Gregory V (gregory.v.rose@intel.com) wrote:
> > >From: Ben Pfaff [mailto:blp@nicira.com]
> > >On Mon, Aug 30, 2010 at 11:26:17AM -0700, Rose, Gregory V wrote:
> > >> I just want to put in a plug for the netlink interface.  For NICs with
> > >> EVB we'll need it.
> > >
> > >Off-hand, the main reasons to use Netlink, instead of the existing
> > >character device interface, are that Netlink is easier to extend and
> > >that it should reduce or eliminate the 32-to-64 bit compat layer
> > >currently in the Open vSwitch tree.
> 
> That, plus it's a typical way to do network configuration.  Esp. with
> bi-directional communication.  So the userspace bit both listens to
> netlink messages, like any of the routing daemons or lldpad or similar
> do, and sends netlink messasges to update driver's flow table.
> 
> BTW, this kind of discussion was why Herbert felt strongly against
> drivers/staging/.  He wanted to be sure the interfaces were well-defined
> first.

Hi Chris,

Is the implication that there is a preference for finalising
the interface (as much as that is possible) before merging?

[ snip ]
