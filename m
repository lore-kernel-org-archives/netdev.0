From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH netdev-2.6] jme: JMicron Gigabit Ethernet Driver
Date: Fri, 21 Nov 2008 00:46:33 -0800 (PST)
Message-ID: <20081121.004633.193696042.davem@davemloft.net>
References: <20081120212045.27879d22@extreme>
	<20081120.213627.210066076.davem@davemloft.net>
	<20081120224542.10feb72d@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, jgarzik@pobox.com, netdev@vger.kernel.org,
	ethanhsiao@jmicron.com, akeem@jmicron.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56112
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752482AbYKUIqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 03:46:33 -0500
In-Reply-To: <20081120224542.10feb72d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 20 Nov 2008 22:45:42 -0800

> On Thu, 20 Nov 2008 21:36:27 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Thu, 20 Nov 2008 21:20:45 -0800
> > 
> > > 6. Not using pci dma allocation which is more standard convention
> > 
> > Using the generic DMA interfaces is actually preferred.  There is
> > no effective difference other than using a more generic interface.
> 
> Ok, but this???

Yes, of course, all of those NAPI et al. abstraction macros have
to go.

I was only commenting about the DMA bits, the rest of your
criticism was on target.
