From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] geneve: fix IPv6 remote address reporting
Date: Fri, 6 May 2016 17:28:20 +0200
Message-ID: <20160506152820.GD11058@orbyte.nwl.cc>
References: <572CAA09.302@solarflare.com>
 <20160506144345.GC11058@orbyte.nwl.cc>
 <572CB4C3.3040708@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33122 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758143AbcEFP2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 11:28:22 -0400
Content-Disposition: inline
In-Reply-To: <572CB4C3.3040708@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 06, 2016 at 04:14:11PM +0100, Edward Cree wrote:
> On 06/05/16 15:43, Phil Sutter wrote:
> > On Fri, May 06, 2016 at 03:28:25PM +0100, Edward Cree wrote:
> >> Since we can only configure unicast, we probably want to be able to
> >> display unicast, rather than multicast.
> > Furthermore, the kernel even rejects multicast peer addresses.
> Yes, but a future kernel might not, and iproute2 is meant to be forward-
> compatible.

Sorry, but I fail to see how this might break forward compatibility.
Quite the contrary, suppose geneve in future supported multicast peers,
current iproute2 would fail to recognize it's existence. What am I
missing here?

> > Why do you then propose a dubious fix to a dubious check instead of
> > getting rid of it in the first place?
> Because John Linville clearly had some reason for putting a check there,
> and he probably knows better than me.  Chesterton's fence.

A valid point, indeed. In my opinion the same applies to your patch as
well, as instead of removing the fence you're moving it to the other
lane. :)

Cheers, Phil
