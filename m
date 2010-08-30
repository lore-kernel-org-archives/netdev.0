From: Ben Pfaff <blp@nicira.com>
Subject: Re: [rfc] Merging the Open vSwitch datapath
Date: Mon, 30 Aug 2010 11:33:28 -0700
Message-ID: <20100830183328.GI7629@nicira.com>
References: <20100830062755.GA22396@verge.net.au>
 <87k4n8ow1r.fsf@benpfaff.org>
 <43F901BD926A4E43B106BF17856F0755F63A08EE@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outmail148095.authsmtp.com ([62.13.148.95]:54154 "EHLO
	outmail148095.authsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755701Ab0H3TGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 15:06:04 -0400
Content-Disposition: inline
In-Reply-To: <43F901BD926A4E43B106BF17856F0755F63A08EE@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[restoring CCs that I inadvertently busted upthread]

On Mon, Aug 30, 2010 at 11:26:17AM -0700, Rose, Gregory V wrote:
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> >On Behalf Of Ben Pfaff
> >
> >Simon Horman <horms@verge.net.au> writes:
> >
> >>    * Possible use of netlink for user-space interface
> >
> >I'm working on this one this week, for what it's worth.
> 
> I just want to put in a plug for the netlink interface.  For NICs with
> EVB we'll need it.

Off-hand, the main reasons to use Netlink, instead of the existing
character device interface, are that Netlink is easier to extend and
that it should reduce or eliminate the 32-to-64 bit compat layer
currently in the Open vSwitch tree.

Why will NICs with EVB require Netlink for the Open vSwitch interface?
