From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] synopsys: remove dwc_eth_qos driver
Date: Thu, 12 Jan 2017 15:54:39 +0000
Message-ID: <066a57f3-29b5-c297-cd67-d9c937b9c9d9@synopsys.com>
References: <2d50f9fea61de2eb082b217d435334d40e3e01ad.1484214626.git.jpinto@synopsys.com>
 <20170112.102802.1485105708725148022.davem@davemloft.net>
 <0eb32fee-0354-522d-72c4-3d1105ec04ed@synopsys.com>
 <20170112.104803.240247212224131685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <lars.persson@axis.com>, <niklass@axis.com>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:52752 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751254AbdALP4T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:56:19 -0500
In-Reply-To: <20170112.104803.240247212224131685.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 3:48 PM de 1/12/2017, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Thu, 12 Jan 2017 15:46:31 +0000
> 
>> Hope we can meet in a LinuxCon soon and have a talk, for you to know
>> me and this way you will see that I am a guy that is only focused in
>> producing work the best way possible, and nothing else.
> 
> I do not argue your intentions.
> 
> I argue the side effects of your change for the ecosystem of
> long term maintaince and backporting, and what tangible benefit
> this change brings to users.
> 

The driver synopsys/dwc_eth_qos is no longer necessary since it was ported to
stmmac. The merged followed all the requirements given by AXIS coleagues Niklas
and Lars. The new stmmac solution was tested by them. In my opinion of course
there is no reason to synopsys/dwc_eth_qos to exist anymore. I am deleting now a
synopsys/ name folder :) I did this work to improve organization and centralize
dwc ethernet in stmmac.

I know that changing what is working properly is a risk, I totally understand,
and if I was a top maintainer I would have the same concern of course. But in
this case I think it is good to organize the house. My intentions are to stick
around and help developing Ethernet, like I am helping developing PCI host/.

Thanks,
Joao
