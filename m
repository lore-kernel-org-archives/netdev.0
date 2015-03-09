From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: smc91x: improve neponset hack
Date: Mon, 09 Mar 2015 13:14:04 -0400 (EDT)
Message-ID: <20150309.131404.2077303491934820826.davem@redhat.com>
References: <5754481.gFE9BvLjh0@wuerfel>
	<20150309122012.GJ8656@n2100.arm.linux.org.uk>
	<20150309123447.GL8656@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, dbaryshkov@gmail.com, netdev@vger.kernel.org,
	linus.walleij@linaro.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: linux@arm.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150309123447.GL8656@n2100.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Mon, 9 Mar 2015 12:34:47 +0000

> On Mon, Mar 09, 2015 at 12:20:12PM +0000, Russell King - ARM Linux wrote:
>> On Fri, Feb 20, 2015 at 04:47:06PM +0100, Arnd Bergmann wrote:
>> > On Thursday 19 February 2015 00:35:49 Russell King - ARM Linux wrote:
>> > > On Wed, Feb 18, 2015 at 08:47:30PM +0100, Arnd Bergmann wrote:
>> > > > The smc91x driver tries to support multiple platforms at compile
>> > > > time, but they are mutually exclusive at runtime, and not clearly
>> > > > defined.
>> > > 
>> > > I'd prefer to rework this to fix that properly.  From what I remember,
>> > > the whole SA11x0 stuff in this driver was a mess.
>> > 
>> > I guess that's reasonable. I've looked through the driver and it seems we
>> > did most of the multiplatform work but left a few things alone that should
>> > have been converted a long time ago.
>> > 
>> > Can you check if the approach below makes sense to you?
>> 
>> I don't know who's carrying what patches, but this is still broken.
>> 
>> arch/arm/mach-sa1100/neponset.c: In function 'neponset_probe':
>> arch/arm/mach-sa1100/neponset.c:271:12: error: 'smc91c_platdata' undeclared (first use in this function)
>> drivers/net/ethernet/smsc/smc91x.c: In function 'smc_drv_probe':
>> drivers/net/ethernet/smsc/smc91x.c:2363:2: error: implicit declaration of function 'machine_has_neponset' [-Werror=implicit-function-declaration]
>> 
>> This is from building Linus' tree as of Saturday plus arm-soc.
>> 
>> Let's revert all this crap and start again, this time testing it better?
> 
> I'm also getting:

I have the fix in my tree still and is pending to be sent to Linus.

Please be patient.
