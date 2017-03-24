From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [v2,net-next,1/3] net: stmmac: enable multiple buffers
Date: Fri, 24 Mar 2017 10:47:41 +0000
Message-ID: <cb5f5af2-6375-111b-e1aa-da48b5c42595@synopsys.com>
References: <1eb1ee4c84f61ff8dbc3f398f2e3f9b0bea3ee30.1489766674.git.jpinto@synopsys.com>
 <20170323171725.GA12548@ulmo.ba.sec>
 <2ec8451b-4d12-d7ea-a2ce-4f1add382df4@synopsys.com>
 <20170324074255.GB16730@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Thierry Reding <thierry.reding@gmail.com>, <davem@davemloft.net>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:53766 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751490AbdCXKta (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 06:49:30 -0400
In-Reply-To: <20170324074255.GB16730@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Às 7:42 AM de 3/24/2017, Andrew Lunn escreveu:
> On Thu, Mar 23, 2017 at 05:27:08PM +0000, Joao Pinto wrote:
> 
>> Yes, you are correct. It should be priv->plat->tx_queues_to_use instead of "u32
>> tx_count = priv->dma_cap.number_tx_queues;"... sorry for that, but in my setup
>> is the same value. Could you please make a patch for it?
> 
> Hi Joao
> 
> As the new maintainer, don't you think you should be testing on
> multiple systems? There are SoC vendor reference design boards you can
> buy, and set up a test farm. You can then ensure your new features
> don't break stuff, or add performance regressions.
> 
>       Andrew
> 

I am not the maintainer of stmmac :), I am just developing on it like everyone
else, just glad to help improving it and adding new features to it. Of course if
the current maintainers invite me to be, I will honored to do so.

Yes it would be fantastic to have a set of boards, but I rarely see this in any
maintainer :). I think it would be nice to have a farm like Linaro has with a
farm of boards donated by each company, enabling tests for everyone in the project.
I have talked with the Prototyping team and I will have an AXI based design,
which will emulate the SoC environment making possible to test the platform
driver scope.

I try as hard as I can to network with people and try to minimize this
situations, but when there is so many different setups using a driver with diff
configurations, situations like this can happen, but I am here to help debugging
and solving them.

Joao
