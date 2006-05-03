From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: VJ Channel API - driver level (PATCH)
Date: Wed, 3 May 2006 22:07:40 +0400
Message-ID: <20060503180740.GA14506@2ka.mipt.ru>
References: <54AD0F12E08D1541B826BE97C98F99F149E880@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Leonid Grossman <Leonid.Grossman@neterion.com>,
	"David S. Miller" <davem@davemloft.net>, shemminger@osdl.org,
	alex@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:39601 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751266AbWECSIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 14:08:18 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
Content-Disposition: inline
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F149E880@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 03, 2006 at 08:56:23AM -0700, Caitlin Bestler (caitlinb@broadcom.com) wrote:
> > I'd expect high end NIC ASICs to implement rx steering based
> > upon some sort of hash (for load balancing), as well as
> > explicit "1:1" steering between a sw channel and a hw
> > channel. Both options for channel configuration are present
> > in the driver interface.
> > If netfilter assists can be done in hardware, I agree the
> > driver interface will need to add support for these -
> > otherwise, netfilter processing will stay above the driver.
> > 
> > 
> 
> Even if the hardware cannot fully implement netfilter rules
> there is still value in having an interface that documents 
> exactly how much filtering a given piece of hardware can do.
> There is no point in having the kernel repeat packet classifications
> that have already been done by the NIC.

Please do not suppose that vj channel must rely on underlaying hardware.
New interface MUST work better or at least not worse than existing skb
queueing for majority of users, and I doubt users with netfilter capable
hardware are there.
It is only some hint to the SW, not rules, that hardware can provide.
The best would be ipv4/ipv6 hashing, and I think it is enough.

-- 
	Evgeniy Polyakov
