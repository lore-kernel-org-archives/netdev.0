From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Thu, 12 Jan 2017 11:09:47 +0000
Message-ID: <dbb59d07-4ab4-37d2-5e70-073091749445@synopsys.com>
References: <cover.1484059674.git.jpinto@synopsys.com>
 <c74e6665ca14a4ca03b38cd3442ef0644d9e250d.1484059674.git.jpinto@synopsys.com>
 <5b5a3231-eed4-ef29-b32a-a19077681dad@gmail.com>
 <a2d2e457-47e5-bb73-a059-0cb907a29ae0@synopsys.com>
 <57d96ccb-7fd4-0707-4902-a5bdd2a6ef39@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <lars.persson@axis.com>, <niklass@axis.com>,
        <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>
To: Alexandre Torgue <alexandre.torgue@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Florian Fainelli <f.fainelli@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:55228 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751206AbdALLOZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 06:14:25 -0500
In-Reply-To: <57d96ccb-7fd4-0707-4902-a5bdd2a6ef39@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex, good morning!

Às 10:11 AM de 1/12/2017, Alexandre Torgue escreveu:
>>
>> Lets not name it synopsys, for me it is totally fine, but naming it
>> stmicro/stmmac is not the right way because it seems like it is a driver just
>> for stmicro products, which is not, is for products that use Designware Ethernet
>> IPs.
>>
>> I am volunteering to do this work, let's discuss this.
> 
> For me it makes no sens to rename only folder (stmicro/stmmac by synopsys) and
> keep stmmac* inside a synopsys folder (that is very confusing). If you propose
> that you have to change all.
> 
> BUT doing that, we will lose all stmmac driver story and we don't want that.

Totally understand your point. Do you agree on this approach?
rename "stmicro" to "dwc" (designware controllers) and leave stmmac as it is
today. This small change is enough in my point of view and sole the problems you
refer. We would have net/ethernet/dwc/stmmac/.

I can also rename the dwmac4 files and functions to eqos, since soon we will
have a new eqos version.

dwmac4.h -> eqos.h
dwmac4_core.c -> eqos_core.c
dwmac4_descs.c -> eqos_descs.c
dwmac4_descs.h -> eqos_descs.h
dwmac4_dma.c -> eqos_dma.c
dwmac4_dma.h -> eqos_dma.h
dwmac4_lib.c -> eqos_lib.c

What do you think about this approach?

Thanks,
Joao

> 
> 
> 
>>
>> Thanks,
>> Joao
>>
>>
