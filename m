From: Jason McMullan <jason.mcmullan@timesys.com>
Subject: Re: [PATCH] MII bus API for PHY devices
Date: Thu, 18 Nov 2004 16:00:47 -0500
Message-ID: <1100811647.14467.52.camel@jmcmullan>
References: <069B6F33-341C-11D9-9652-000393DBC2E8@freescale.com>
	 <9B0D9272-398A-11D9-96F6-000393C30512@freescale.com>
	 <1100806489.14467.47.camel@jmcmullan>
	 <2B68D9FA-399B-11D9-96F6-000393C30512@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "<netdev@oss.sgi.com>" <netdev@oss.sgi.com>,
        "<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <2B68D9FA-399B-11D9-96F6-000393C30512@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-11-18 at 13:50 -0600, Andy Fleming wrote:
> Jason McMullan said:
> >
> > Actually, each PHY should have it's own device directory, like every
> > other device. Eventually, PHYs should have /dev/phy* entries, where
> > user-space can read/write PHY registers.
> 
> I think you misunderstood.  Are you talking about sysfs?  I was talking 
> about actual source files.  i.e. should there be dm9161.c, m88e1101.c, 
> cis8201.c, etc.

	Yes, I am talking about sysfs. And yes, I think every PHY should have
it's own .c file. (although most people could get away with
using a non-IRQ 'drivers/net/phy/phy-generic.c'

> Also, do we need user-space to read/write PHY registers.  ethtool has 
> this capability, I believe, and the interfaces there are settled.

Doh! I forgot.

-- 
Jason McMullan <jason.mcmullan@timesys.com>
