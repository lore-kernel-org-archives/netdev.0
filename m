From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "smc91x: retrieve IRQ and trigger flags in a
 modern way"
Date: Thu, 19 Feb 2015 15:28:41 -0500 (EST)
Message-ID: <20150219.152841.891912250243016754.davem@davemloft.net>
References: <1423760350-20149-1-git-send-email-robert.jarzmik@free.fr>
	<CACRpkdZGze_2=hWe414Eum_9hpNXgog5vmu6Y4R_zhg0x2z0SQ@mail.gmail.com>
	<87bnkx6bja.fsf@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linus.walleij@linaro.org, nico@fluxnic.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87bnkx6bja.fsf@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Fri, 13 Feb 2015 17:06:49 +0100

> Linus Walleij <linus.walleij@linaro.org> writes:
> 
>> On Fri, Feb 13, 2015 at 12:59 AM, Robert Jarzmik <robert.jarzmik@free.fr> wrote:
>>
>> But isn't the real problem that in the device tree case,
>> irq_get_irq_data(ndev->irq) will work becaus parsing an interrupt
>> from the device tree populates it correctly in platform_get_irq()
>> whereas for the legacy lookup it just fetches the number.
>>
>> So to me it seems like a weakness in the platform_get_irq()
>> helper altogether.
>>
>> Does the following work? (I can send as a separate patch for
>> testing if you like).
> 
> Almost. If you replace :
>> +    if (r->flags & IORESOURCE_BITS)
> with:
>> +    if (r && r->flags & IORESOURCE_BITS)
> 
> Then you can push a patch with my:
> Tested-by: Robert Jarzmik <robert.jarzmik@free.fr>
> 
> Now if you can make it in -rc2 or -rc3, this revert should be forgotten. But if
> you can't make it for 3.20, I'll push for the revert.
> 
> So I think it's up to you now, and let's see what Gregh says about it.

What is the current status of this?  I'd like to see this move forward so we
can get this fixed ASAP.

Thanks.
