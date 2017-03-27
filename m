From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [v2,net-next,1/3] net: stmmac: enable multiple buffers
Date: Mon, 27 Mar 2017 10:34:39 +0100
Message-ID: <22b73b28-135e-0e4b-c2b4-b4348e07d686@synopsys.com>
References: <20170324074255.GB16730@lunn.ch>
 <cb5f5af2-6375-111b-e1aa-da48b5c42595@synopsys.com>
 <20170324111736.GB22281@lunn.ch>
 <20170324.100557.1391035515160209574.davem@davemloft.net>
 <742f3185-1b4e-f801-5b5e-cc835953ff0c@synopsys.com>
 <13caf663-ba0f-941c-0d1e-f043cb9a7a0b@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, <andrew@lunn.ch>,
        <thierry.reding@gmail.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>
To: Alexandre Torgue <alexandre.torgue@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:58225 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752136AbdC0Jgw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 05:36:52 -0400
In-Reply-To: <13caf663-ba0f-941c-0d1e-f043cb9a7a0b@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 10:28 AM de 3/27/2017, Alexandre Torgue escreveu:
> Hi Joao
> 
> On 03/24/2017 06:09 PM, Joao Pinto wrote:
>>
>> Hello David,
>>
>> Às 5:05 PM de 3/24/2017, David Miller escreveu:
>>> From: Andrew Lunn <andrew@lunn.ch>
>>> Date: Fri, 24 Mar 2017 12:17:36 +0100
>>>
>>>>> Yes it would be fantastic to have a set of boards, but I rarely see this in
>>>>> any
>>>>> maintainer :).
>>>>
>>>> Being a Marvell SoC and switch maintainer, i have around a dozen
>>>> boards. Some i got some simply by asking the manufacture, others i
>>>> purchased. I don't think i'm in the minority here. Without having
>>>> access to a number of different hardwares, i don't feel i would be
>>>> doing my work properly.
>>>>
>>>>> I try as hard as I can to network with people and try to minimize this
>>>>> situations, but when there is so many different setups using a driver with
>>>>> diff
>>>>> configurations, situations like this can happen, but I am here to help
>>>>> debugging
>>>>> and solving them.
>>>>
>>>> You made a move to rename stmmac to synopsys not long ago. It gave the
>>>> impression that synopsis wants to take over this driver. If there are
>>>> a number of different configurations, who better than synopsys to
>>>> actually properly test these configurations? If you ask around, i'm
>>>> sure people will send you hardware.
>>>
>>> I completely agree with everything Andrew is saying here.
>>>
>>
>> I'll maintain the driver if everyone agrees with it, no problem, mas I would
>> like to hear from Peppe and Alex, since they are the current maintainers.
> 
> I agree with this proposition. As you can see (and unfortunately) I have
> currently no time for reviewing (I'm busy on another subsystem). You are close
> to new GMAC evolution and very active (I hope for a long time).
> For sure you need boards with old GMAC Ips. I will send you an STM32 with GMAC
> IP 3.5. Don't hesitate to contact us if you have question about historic content
> of stmmac driver.

Thanks Alex, I will do my best to maintain it! That would be great to have a
board with an older IP to test. I will send you my office address soon. Thanks!

@ Peppe: Are you ok with it?

Thanks.

> 
> Thanks!
> 
> Alex
> 
> 
> 
>>
>> HW testing would be nice, but hard to justify investing in one shot, so it would
>> be great to receive hardware to make tests if the companies wish it.
>>
>> About the problems in the last patch I am going to send a 2 patch set with 2
>> fixes, lets see if stuff gets better.
>>
>> Thnaks
>> Joao
>>
