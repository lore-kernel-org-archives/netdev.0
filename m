From: Joe Perches <joe@perches.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 12:56:01 -0700
Message-ID: <1251230161.24767.57.camel@Joe-Laptop.home>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>
	 <alpine.DEB.1.10.0908251514190.17963@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, niv@linux.vnet.ibm.com,
	sri@linux.vnet.ibm.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1370 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754836AbZHYT4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 15:56:01 -0400
In-Reply-To: <alpine.DEB.1.10.0908251514190.17963@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-08-25 at 15:15 -0400, Christoph Lameter wrote:
> On Tue, 25 Aug 2009, David Stevens wrote:
> > Christoph Lameter <cl@linux-foundation.org> wrote on 08/25/2009 06:48:24
> > AM:
> > > On Mon, 24 Aug 2009, Sridhar Samudrala wrote:
> > > > If we count these drops as qdisc drops, should we also count them as
> > IP OUTDISCARDS?
> > > Yes.
> > Actually, no. (!)
> > IP_OUTDISCARDS should count the packets IP dropped, not
> > anything dropped at a lower layer (which, in general, it
> > is not aware of). If you count these in multiple layers,
> > then you don't really know who dropped it.
> They need to be accounted at the qdisc level though.

It's probably useful to be able to know when packets
and payloads are dropped.  It may not be necessary though.
It's probably not a fundamental.

Chariot, LANforge and apps like it might care, but most all
other apps might not care at all.

Maybe these should be allowed with a CONFIG.


