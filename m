From: "David S. Miller" <davem@davemloft.net>
Subject: Re: VJ Channel API - driver level (PATCH)
Date: Wed, 03 May 2006 13:35:16 -0700 (PDT)
Message-ID: <20060503.133516.104938819.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F149E880@NT-SJCA-0751.brcm.ad.broadcom.com>
	<20060503180740.GA14506@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, Leonid.Grossman@neterion.com,
	shemminger@osdl.org, alex@neterion.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57240
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750826AbWECUfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 16:35:17 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060503180740.GA14506@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 3 May 2006 22:07:40 +0400

> On Wed, May 03, 2006 at 08:56:23AM -0700, Caitlin Bestler (caitlinb@broadcom.com) wrote:
> > > I'd expect high end NIC ASICs to implement rx steering based
> > > upon some sort of hash (for load balancing), as well as
> > > explicit "1:1" steering between a sw channel and a hw
> > > channel. Both options for channel configuration are present
> > > in the driver interface.
> > > If netfilter assists can be done in hardware, I agree the
> > > driver interface will need to add support for these -
> > > otherwise, netfilter processing will stay above the driver.
> > > 
> > > 
> > 
> > Even if the hardware cannot fully implement netfilter rules
> > there is still value in having an interface that documents 
> > exactly how much filtering a given piece of hardware can do.
> > There is no point in having the kernel repeat packet classifications
> > that have already been done by the NIC.
> 
> Please do not suppose that vj channel must rely on underlaying hardware.

I am not.  I am just saying that it is futile to build hardware that
cannot handle netfilter at least to some extent, because this will
result in HW net channels being disabled for %99 of real users which
makes the hardware just a waste.
