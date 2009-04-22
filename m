From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: What makes a good fake MAC address?
Date: Wed, 22 Apr 2009 15:25:39 -0700
Message-ID: <20090422152539.7a7e073a@s6510>
References: <20090423070442.1e643b5b.ipng@69706e6720323030352d30312d31340a.nosense.org>
	<200904221515.05459.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>,
	netdev@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57572 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752890AbZDVWZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 18:25:41 -0400
In-Reply-To: <200904221515.05459.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Apr 2009 15:15:05 -0700
Inaky Perez-Gonzalez <inaky@linux.intel.com> wrote:

> On Wednesday 22 April 2009, Mark Smith wrote:
> > Hi Inaky,
> >
> > (please CC me, I'm not on the list)
> >
> > "The problem with using a zero mac address is that it confuses the
> > bridging software (and maybe others). I was wondering, what would
> > be a fake mac address we could put in there that is legal for this
> > kind of "faking"? [or the closest thing to legal?]"
> >
> > Since you're from an organisation with an OUI allocation or two, I
> > think a real Intel one would be best. It then wouldn't be fake, and
> > no matter where it was exposed (host only, local network, or
> > globally e.g. in IPv6 node addresses), it would be guaranteed not
> > to collide with any other addresses (unless Intel make error an
> > error in their own OUI administration.)
> 
> It doesn't really work, because it is for the "from" end of the
> connection; as said somewhere else in the thread, the WiMAX link is
> P2P, IP only. The card has a local address, that we use for the "to"
> field, but for the from, we need to fake an address from the network
> -- which is not necessarily an intel device :)
> 
> So maybe local addresses would not be the right choice, and clearly
> Intel assigned ones neither :)
> 

You need a from address for the bridge to be able to populate its
forwarding table. If remote end is always same, just get some random
address at start of tunnel and reuse it.

