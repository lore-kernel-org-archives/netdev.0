From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] MII bus API for PHY devices
Date: Thu, 18 Nov 2004 13:50:59 -0600
Message-ID: <2B68D9FA-399B-11D9-96F6-000393C30512@freescale.com>
References: <069B6F33-341C-11D9-9652-000393DBC2E8@freescale.com> <9B0D9272-398A-11D9-96F6-000393C30512@freescale.com> <1100806489.14467.47.camel@jmcmullan>
Mime-Version: 1.0 (Apple Message framework v619)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "<netdev@oss.sgi.com>" <netdev@oss.sgi.com>,
        "<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1100806489.14467.47.camel@jmcmullan>
To: Jason McMullan <jason.mcmullan@timesys.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Nov 18, 2004, at 13:34, Jason McMullan wrote:
>> 3) How should we bind ethernet drivers to PHY drivers?
>
> A PHY 'platform_data' struct like:
>
> struct phy_device_data {
> 	struct {
> 		const char *name;
> 		int id;
> 	} ethernet_platform_device_parent;
> 	int	phy_id;
> }

So you would have each PHY know the controller to which it's attached?  
I would have thought the other way around... Hm.  I will definitely 
have to read up on my driver model stuff

> 	
>> Oh, and a 4th side-issue:
>> Should each PHY have its own file?
>
> Actually, each PHY should have it's own device directory, like every
> other device. Eventually, PHYs should have /dev/phy* entries, where
> user-space can read/write PHY registers.

I think you misunderstood.  Are you talking about sysfs?  I was talking 
about actual source files.  i.e. should there be dm9161.c, m88e1101.c, 
cis8201.c, etc.

Also, do we need user-space to read/write PHY registers.  ethtool has 
this capability, I believe, and the interfaces there are settled.

Andy Fleming
