From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6 multicast routing
Date: Sun, 25 Jan 2009 18:15:10 -0800 (PST)
Message-ID: <20090125.181510.81366979.davem@davemloft.net>
References: <20090120200248.GA13928@boeing.com>
	<20090121.100431.126366547.yoshfuji@linux-ipv6.org>
	<21C34AA2609529459A85739E2952066904A9670D@XCH-NW-9V1.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	Fred.L.Templin@boeing.com
To: Thomas.Goff@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45814
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751107AbZAZCPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2009 21:15:08 -0500
In-Reply-To: <21C34AA2609529459A85739E2952066904A9670D@XCH-NW-9V1.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Goff, Thomas" <Thomas.Goff@boeing.com>
Date: Thu, 22 Jan 2009 15:30:38 -0800

> On Wed, Jan 21, 2009 at 10:04:31AM +0900, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> 
> > >   - Enable/disable IPv6 multicast forwarding on the corresponding
> > >     interface when a routing daemon adds/removes a multicast virtual
> > >     interface.
> :
> > However, I believe configuring forwarding is user's responsibility
> > and I'm not in favor of managing mc_forwarding automatically.
> >
> > If we go your way, we need to make the proc interface read-only, but
> > you know, they will become non-"conf" interface. :-(
> > And, well, we will introduce another possible overflow/underflow here...
> >
> > Another thought was to allow non-VIF routing settings (or manual settings).
> >
> > So, I decided to drop that bits.
> 
> Thanks for looking it over.
> 
> I think your approach to handling mc_forwarding makes sense, although
> it differs from the IPv4 behavior.  In any case, it looks like the
> current IPv4 and IPv6 multicast routing code does not consider an
> interface's mc_forwarding value at all.

Thanks guys.

Hideaki-san, did you queue this patch up or do you want me to
apply it with the mc_forwarding counter bumps removed?

These are bug fixes so I'd like to see this in the tree soon.
