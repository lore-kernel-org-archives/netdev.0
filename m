From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] net: phy: spi_ks8995: add dependency on GPIO
Date: Fri, 19 Feb 2016 11:13:23 -0500 (EST)
Message-ID: <20160219.111323.1588037348332012027.davem@davemloft.net>
References: <1455372195-10825-1-git-send-email-sudipm.mukherjee@gmail.com>
	<20160216.203606.1431228679408727525.davem@davemloft.net>
	<20160219082909.GA6312@sudip-pc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org, helmut.buchsbaum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160219082909.GA6312@sudip-pc>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Fri, 19 Feb 2016 13:59:09 +0530

> On Tue, Feb 16, 2016 at 08:36:06PM -0500, David Miller wrote:
>> From: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Sat, 13 Feb 2016 19:33:15 +0530
>> 
>> > The builds of allmodconfig of s390, m68k, tilegx, tilepro is failing
>> > with the error:
>> >  drivers/net/phy/spi_ks8995.c:477:3: error: implicit declaration of function 'gpiod_set_value'
>> >  drivers/net/phy/spi_ks8995.c:477:19: error: implicit declaration of function 'gpio_to_desc'
 ...
> I think Arnd's patch is still not applied as we are still having build
> failures for the implicit declarations. Or you want me to send v3 after
> removing unnecessary linux/gpio.h include?

It's definitely there in net-next, commit 27090cbdc345cd5fd6f6e57a8986c504c27e4d23
