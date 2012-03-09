From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 1/4] phy: add the EEE support and the way to access
 to the MMD regs
Date: Fri, 09 Mar 2012 15:39:45 +0100
Message-ID: <4F5A1631.9010006@st.com>
References: <4F4E4D4B.3040909@st.com>   <1331022494-12891-1-git-send-email-peppe.cavallaro@st.com>   <1331022494-12891-2-git-send-email-peppe.cavallaro@st.com>   <1331052913.2333.16.camel@bwh-desktop>  <1331053557.2333.19.camel@bwh-desktop> <4F58C821.3040104@st.com> <1331231373.2481.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	rayagond@vayavyalabs.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:57877 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756671Ab2CIOka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 09:40:30 -0500
In-Reply-To: <1331231373.2481.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/8/2012 7:29 PM, Ben Hutchings wrote:
> On Thu, 2012-03-08 at 15:54 +0100, Giuseppe CAVALLARO wrote:
>> Hello Ben
>>
>> thanks for your review and sorry for my delay.
>>
>> On 3/6/2012 6:05 PM, Ben Hutchings wrote:
> [...]
>>>>> +static inline void mmd_phy_cl45(struct mii_bus *bus, int prtad, int devad,
>>>>> +				int addr)
>>>> [...]
>>>>> +/**
>>>>> + * read_phy_mmd - reads data from the MMC register (clause 22 to access to
>>>>> + * clause 45)
>>>> [...]
>>>>> +/**
>>>>> + * write_phy_mmd - writes data to the MMC register (clause 22 to access to
>>>>> + * clause 45)
>>>>
>>>> These names need to be changed as phylib also supports (or is intended
>>>> to support) real clause 45 PHYs.
>>
>>
>> What do you suggest? Do I have to rename these functions for example as?
>>
>> write_phy_mmd  ---->    phy_write_mmd_cl45
>> read_phy_mmd   ---->    phy_read_mmd_cl45
> 
> These are a means to access MMDs through the clause 22 MDIO protocol, so

yes indeed :-)

> it seems to me that the name should include '22' and not '45'.  But
> perhaps it would be more obvious to use the word 'indirect'.

ok for phy_write/read_mmd_indirect

> 
>> I've also another doubt. I put this code in phy_device.c. Is it correct?
>>
>> Maybe, it could be better have it in phy.c? What do you think?
> [...]
> 
> No idea, I don't have any involvement in phylib.

ok. I'll keep the code in phy_device unless to have further feedback
from other developers.

peppe

> 
> Ben.
> 
