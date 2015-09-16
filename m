From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] net: smc91x: convert pxa dma to dmaengine
Date: Wed, 16 Sep 2015 11:41:54 +0200
Message-ID: <87a8smsntp.fsf@belgarion.home>
References: <1441913164-3785-1-git-send-email-robert.jarzmik@free.fr>
	<20150915.162414.1153837609419205002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nico@fluxnic.net, arnd@arndb.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150915.162414.1153837609419205002.davem@davemloft.net> (David
	Miller's message of "Tue, 15 Sep 2015 16:24:14 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Robert Jarzmik <robert.jarzmik@free.fr>
> Date: Thu, 10 Sep 2015 21:26:04 +0200
>
>> Convert the dma transfers to be dmaengine based, now pxa has a dmaengine
>> slave driver. This makes this driver a bit more PXA agnostic.
>> 
>> The driver was tested on pxa27x (mainstone) and pxa310 (zylonite),
>> ie. only pxa platforms.
>> 
>> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
>> Cc: Russell King <linux@arm.linux.org.uk>
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> ---
>> This has potential to break other platform such as Neponset, Idp,
>> halibut and qsd8x50, so I added Russell and Arnd as they were discussing
>> smc91x support last February.
>

> Is someone testing whether such platforms break or not?  I'm waiting for
> that before I consider applying this patch.

My understanding is that Russell is the only one left testing them, or at least
he was the only one complaining about a breakage lately on neponset.

I can wait several weeks for Russell to have a bit of time to try : I know it
will compile correctly at least for neponset, and I know almost all the code is
under #ifdef CONFIG_ARCH_PXA. And still I would feel far more comfortable if it
was tested, just as you.

Cheers.

-- 
Robert
