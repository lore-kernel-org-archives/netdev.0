From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH] synopsys: remove dwc_eth_qos driver
Date: Fri, 13 Jan 2017 10:26:59 +0100
Message-ID: <47eecb42-f685-7db7-f265-7c22ddf73cfd@axis.com>
References: <2d50f9fea61de2eb082b217d435334d40e3e01ad.1484214626.git.jpinto@synopsys.com>
 <20170112.102802.1485105708725148022.davem@davemloft.net>
 <0eb32fee-0354-522d-72c4-3d1105ec04ed@synopsys.com>
 <20170112.104803.240247212224131685.davem@davemloft.net>
 <066a57f3-29b5-c297-cd67-d9c937b9c9d9@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <larper@axis.com>, <peppe.cavallaro@st.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:54056 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750923AbdAMJ1D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 04:27:03 -0500
In-Reply-To: <066a57f3-29b5-c297-cd67-d9c937b9c9d9@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 04:54 PM, Joao Pinto wrote:
> Às 3:48 PM de 1/12/2017, David Miller escreveu:
>> From: Joao Pinto <Joao.Pinto@synopsys.com>
>> Date: Thu, 12 Jan 2017 15:46:31 +0000
>>
>>> Hope we can meet in a LinuxCon soon and have a talk, for you to know
>>> me and this way you will see that I am a guy that is only focused in
>>> producing work the best way possible, and nothing else.
>> I do not argue your intentions.
>>
>> I argue the side effects of your change for the ecosystem of
>> long term maintaince and backporting, and what tangible benefit
>> this change brings to users.
>>
> The driver synopsys/dwc_eth_qos is no longer necessary since it was ported to
> stmmac. The merged followed all the requirements given by AXIS coleagues Niklas
> and Lars. The new stmmac solution was tested by them. In my opinion of course
> there is no reason to synopsys/dwc_eth_qos to exist anymore. I am deleting now a
> synopsys/ name folder :) I did this work to improve organization and centralize
> dwc ethernet in stmmac.

Hello Joao, David.

Regardless of the outcome of the "to rename or not to rename"
discussion, I think that merging this patch would be a good thing.

Joao's dwc_eth_qos glue layer has been merged to stmmac,
so it should now be safe to remove the dwc_eth_qos driver.

It's much better if everyone is focusing on a single driver.

>
> I know that changing what is working properly is a risk, I totally understand,
> and if I was a top maintainer I would have the same concern of course. But in
> this case I think it is good to organize the house. My intentions are to stick
> around and help developing Ethernet, like I am helping developing PCI host/.
>
> Thanks,
> Joao
