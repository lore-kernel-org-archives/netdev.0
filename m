From: David Miller <davem@davemloft.net>
Subject: Re: tulip_stop_rxtx() failed (CSR5 0xf0260000 CSR6 0xb3862002) on
 DEC Alpha Personal Workstation 433au
Date: Wed, 07 Apr 2010 22:01:07 -0700 (PDT)
Message-ID: <20100407.220107.55136830.davem@davemloft.net>
References: <20100405171318.GA18915@physik.fu-berlin.de>
	<1270488982.31062.28.camel@Joe-Laptop.home>
	<20100407134228.GC31252@physik.fu-berlin.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, grundler@parisc-linux.org, kyle@mcmartin.ca,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: glaubitz@physik.fu-berlin.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100407134228.GC31252@physik.fu-berlin.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 7 Apr 2010 15:42:28 +0200

> Hi,
> 
> On Mon, Apr 05, 2010 at 10:36:22AM -0700, Joe Perches wrote:
>> On Mon, 2010-04-05 at 19:13 +0200, Adrian Glaubitz wrote:
>> > Hi guys,
>> > 
>> > I installed Debian unstable on an old digital workstation "DEC Digital
>> > Personal Workstation 433au" (Miata) which has an on-board tulip
>> > network controller. I'm not really using that network controller but
>> > an off-board intel e1000 controller. However, I found that the tulip
>> > driver produces a lot of noise in the message log, the following
>> > message is repated periodically and spams the whole message log:
>> > 
>> > 0000:00:03.0: tulip_stop_rxtx() failed (CSR5 0xf0260000 CSR6 0xb3862002)
>> > 
>> > Do you think this is related to the fact that no cable is connected to
>> > the network controller?
>> 
>> Probably something is trying periodically to open the device.
>> Maybe this helps reduce the message log noise:
>> 
>> Signed-off-by: Joe Perches <joe@perches.com>
> 
> Acked-by: Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
> 
> Patch works perfectly. Now the message log looks pretty normal.

This doesn't fix the problem, it just makes the message get
emitted in a rate limited manner.

I'm not going to apply this, we need to figure out what's causing
this problem instead of merely papering over it.

Thanks.
