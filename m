From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [Linux-kernel] [PATCH] sh_eth: call of_mdiobus_register() to
 register phys
Date: Mon, 17 Feb 2014 16:44:24 +0000
Message-ID: <53023C68.8010201@codethink.co.uk>
References: <1392650895-1422-1-git-send-email-ben.dooks@codethink.co.uk> <53023B60.4030201@cogentembedded.com> <53022EE4.50607@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, netdev@vger.kernel.org,
	magnus@opensource.se, linux-sh@vger.kernel.org,
	horms+renesas@verge.net.au
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <53022EE4.50607@codethink.co.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/02/14 15:46, Ben Dooks wrote:
> On 17/02/14 16:40, Sergei Shtylyo

[snip]

>
>>> +        return 0;
>>> +    }
>>> +
>>>       /* PHY IRQ */
>>>       mdp->mii_bus->irq = devm_kzalloc(&ndev->dev,
>>>                        sizeof(int) * PHY_MAX_ADDR,
>>>
>>
>>      Hm, I can only hope this works with PHY IRQ in DT mode.
>> Would you mind if I include your patch into my Ether DT patch?
>
> You are welcome to include it in your series, but I would like
> to keep the credit for finding this.
>
> Also, FYI, for some reason the probe is not finding the correct
> IRQ for this. I will have a look later when I get the board back
> as to why this is:
>
> net eth0: attached PHY 1 (IRQ -1) to driver Micrel KSZ8041RNLI

I've sent a fix for of_mdio to set phy->irq correctly and will
re-send this as a v2 patch shortly.

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
