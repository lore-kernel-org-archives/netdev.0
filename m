From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] net: smc91x: improve neponset hack
Date: Fri, 20 Feb 2015 21:00:32 +0100
Message-ID: <87twyg73q7.fsf@free.fr>
References: <5763365.j5Nvv4LgM3@wuerfel>
	<20150219003549.GY8656@n2100.arm.linux.org.uk>
	<5754481.gFE9BvLjh0@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-arm-kernel@lists.infradead.org,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	netdev@vger.kernel.org, Linus Walleij <linus.walleij@linaro.org>,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Arnd Bergmann <arnd@arndb.de>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5754481.gFE9BvLjh0@wuerfel> (Arnd Bergmann's message of "Fri, 20
	Feb 2015 16:47:06 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> On Thursday 19 February 2015 00:35:49 Russell King - ARM Linux wrote:
>> On Wed, Feb 18, 2015 at 08:47:30PM +0100, Arnd Bergmann wrote:
>> > The smc91x driver tries to support multiple platforms at compile
>> > time, but they are mutually exclusive at runtime, and not clearly
>> > defined.
>> 
>> I'd prefer to rework this to fix that properly.  From what I remember,
>> the whole SA11x0 stuff in this driver was a mess.
>
> I guess that's reasonable. I've looked through the driver and it seems we
> did most of the multiplatform work but left a few things alone that should
> have been converted a long time ago.
>
> Can you check if the approach below makes sense to you?
>
> I've verified that each machine that defines an smc91x device now sets
> the correct platform data, irq flags and access width, which should be
> enough to collapse all the CONFIG_ARM cases into one.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
When you're both satisfied with the smc91x patch, I can offer to test it across
the pxa boards (lubbock, zylonite, and maybe mainstone). As I'm actively using
the first 2, I'm interested in them being as functional as now :)

Cheers.

--
Robert
