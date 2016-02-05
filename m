From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] net: smc911x: convert pxa dma to dmaengine
Date: Fri, 05 Feb 2016 22:44:56 +0100
Message-ID: <87k2mi4ysn.fsf@belgarion.home>
References: <1448919628-13273-1-git-send-email-robert.jarzmik@free.fr>
	<20151202.235217.2201517065767030121.davem@davemloft.net>
	<87fuzjl69l.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alberto Panizzo <maramaopercheseimorto@gmail.com>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87fuzjl69l.fsf@belgarion.home> (Robert Jarzmik's message of
	"Thu, 03 Dec 2015 19:46:30 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Jarzmik <robert.jarzmik@free.fr> writes:

> David Miller <davem@davemloft.net> writes:
>
>> From: Robert Jarzmik <robert.jarzmik@free.fr>
>> Date: Mon, 30 Nov 2015 22:40:28 +0100
>>
>>> Convert the dma transfers to be dmaengine based, now pxa has a dmaengine
>>> slave driver. This makes this driver a bit more PXA agnostic.
>>> 
>>> The driver was only compile tested. The risk is quite small as no
>>> current PXA platform I'm aware of is using smc911x driver.
>>> 
>>> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
>>
>> I've marked this 'deferred' in patchwork until someone tests
>> these changes and says they should be good on all platforms
>> this chip is used.
>
> Okay, so would any maintainer of non pxa boards give a feedback for this patch ?
> The ones I have found are :
>  - sh2007: Guennadi and Hitoshi
>  - armadillo5x0: Alberto
>  - imx v6 and imx v7: Fabio
> I've added the patch at the end of this mail for easier handling.
>
> Now, if no maintainer gives it a test, what do we do, David ? I'm intending to
> remove "arch/arm/mach-pxa/include/mach/dma.h" in the near future, which will
> break this driver somehow (at least for PXA boards, even if none is identified
> so far).
> So could we agree on a deadline, and what you wish to do : either drop the patch
> or apply, or something else.

Hi David,

Apart from Alberto who answered he cannot test it by lack of hardware, the
others didn't answer.

So how can I move forward ? Would you want me to amend the KConfig to add a "&&
!ARCH_PXA" on the "depend" line ?

Cheers.

-- 
Robert
