From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] sh_eth: call of_mdiobus_register() to register phys
Date: Tue, 18 Feb 2014 17:39:20 +0000
Message-ID: <53039AC8.1010802@codethink.co.uk>
References: <1392650895-1422-1-git-send-email-ben.dooks@codethink.co.uk> <53023B60.4030201@cogentembedded.com> <53022EE4.50607@codethink.co.uk> <53038C6A.1000600@cogentembedded.com> <530383BB.60102@codethink.co.uk> <5303A26D.9050301@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms+renesas@verge.net.au,
	linux-sh@vger.kernel.org, magnus@opensource.se,
	linux-kernel@lists.codethink.co.uk
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5303A26D.9050301@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/02/14 18:11, Sergei Shtylyov wrote:
> Hello.
>
> On 02/18/2014 07:00 PM, Ben Dooks wrote:
>
>>>>>> If the sh_eth device is registered using OF, then the driver
>
>>>>>     Which is not supported yet as my DT patch hasn't been merged.
>>>>> This patch seems somewhat premature.
>
>>>> I've got your OF patches in my local tree to test with, this
>>>> is what I found during that testing.
>
>>>     The issue is that I didn't post my v3 patch to netdev due to
>>> net-next.git repo being closed at this moment and DaveM not wanting to
>>> see any patch targeted to it during this time. I've now posted v4 of my
>>> Ether DT patch to netdev.
>
>> Ok, I will look for these tomorrow.
>
>     No significant changes there...
>
>>>>>> should call of_mdiobus_register() to register any PHYs connected
>>>>>> to the system.
>
>>>>>     That's not necessary (but good to have).
>
>>>> Well, it is necessary if you then want any PHYS bound to
>>>> the device to have their OF information to hand,
>
>>>     Ether DT support worked for me without this fragment, at least.
>
>> Yes, it just that the PHY is not being linked to the relevant
>> OF node. The PHY gets bound, it will not be able to find the
>> DT info passed.
>
>     With no DT support in the PHY driver, I don't see how it matters.
> Perhaps it has to do with your "init-regs" prop patch though...


Yes, or if we add some other properties to the PHY node to say
how to initialise the registers, such as if the PHY node had.

I am going to look in to adding led<name> initialisers to the
PHY node in case people do not like my init-regs patch.


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
