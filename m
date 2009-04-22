From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: What makes a good fake MAC address?
Date: Wed, 22 Apr 2009 15:38:10 -0700
Message-ID: <200904221538.10964.inaky@linux.intel.com>
References: <20090423070442.1e643b5b.ipng@69706e6720323030352d30312d31340a.nosense.org> <200904221515.05459.inaky@linux.intel.com> <20090422152539.7a7e073a@s6510>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:10862 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750825AbZDVWiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 18:38:11 -0400
In-Reply-To: <20090422152539.7a7e073a@s6510>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 22 April 2009, Stephen Hemminger wrote:
> On Wed, 22 Apr 2009 15:15:05 -0700
>
> Inaky Perez-Gonzalez <inaky@linux.intel.com> wrote:
> > On Wednesday 22 April 2009, Mark Smith wrote:
> > > Hi Inaky,
> > >
> > > (please CC me, I'm not on the list)
> > >
> > > "The problem with using a zero mac address is that it confuses the
> > > bridging software (and maybe others). I was wondering, what would
> > > be a fake mac address we could put in there that is legal for this
> > > kind of "faking"? [or the closest thing to legal?]"
> > >
> > > Since you're from an organisation with an OUI allocation or two, I
> > > think a real Intel one would be best. It then wouldn't be fake, and
> > > no matter where it was exposed (host only, local network, or
> > > globally e.g. in IPv6 node addresses), it would be guaranteed not
> > > to collide with any other addresses (unless Intel make error an
> > > error in their own OUI administration.)
> >
> > It doesn't really work, because it is for the "from" end of the
> > connection; as said somewhere else in the thread, the WiMAX link is
> > P2P, IP only. The card has a local address, that we use for the "to"
> > field, but for the from, we need to fake an address from the network
> > -- which is not necessarily an intel device :)
> >
> > So maybe local addresses would not be the right choice, and clearly
> > Intel assigned ones neither :)
>
> You need a from address for the bridge to be able to populate its
> forwarding table. If remote end is always same, just get some random
> address at start of tunnel and reuse it.

Nope, the remote end will change as you move around from base station to base 
station :(

-- 
Inaky
