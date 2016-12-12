From: Stephen Warren <swarren@nvidia.com>
Subject: RE: Re: Synopsys Ethernet QoS
Date: Mon, 12 Dec 2016 16:46:41 +0000
Message-ID: <45e38628c16c4236ad0d2d49a32a0eb5@HQMAIL107.nvidia.com>
References: <2df7a6dd-1128-d1d6-bf61-891f76cf7200@synopsys.com>
 <20161209.103327.1742213347114742435.davem@davemloft.net>
 <93b73b79-36aa-56b8-f975-b890b7a48bd1@synopsys.com>
 <20161209.104152.1969880574279771010.davem@davemloft.net>
 <CAHp75VcKURaTQX9=SY8+46GGATuwO1oXAi8eMS+uwk58sjKx5Q@mail.gmail.com>
 <3aee5a67-5e19-34e6-1719-ff13c7b914ea@gmail.com>
 <CAHp75VfT9B3O5jU0eHoKtgYc48K2ZjCQ-g9ZQ9nX1Hew6tz-zw@mail.gmail.com>
 <556353b7-c847-7549-626d-3c324063647e@gmail.com>
 <f5357ea2-a295-ab08-046e-f8b8f6ca4344@synopsys.com>
 <1d445ec1-deb8-6e36-39c4-6813c446095f@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        "larper@axis.com" <larper@axis.com>,
        "rabinv@axis.com" <rabinv@axis.com>,
        netdev <netdev@vger.kernel.org>,
        "CARLOS.PALMINHA@synopsys.com" <CARLOS.PALMINHA@synopsys.com>,
        "Jie.Deng1@synopsys.com" <Jie.Deng1@synopsys.com>,
        "pavel@ucw.cz" <pavel@ucw.cz>, Thierry Reding <treding@nvidia.com>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "Andy Shevchenko" <andy.shevchenko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate14.nvidia.com ([216.228.121.143]:19153 "EHLO
        hqemgate14.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752488AbcLLQrK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 11:47:10 -0500
In-Reply-To: <1d445ec1-deb8-6e36-39c4-6813c446095f@axis.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Niklas Cassel wrote at Monday, December 12, 2016 9:25 AM:
...
> However, I've noticed that NVIDIA has extended the DWC EQoS DT binding,
> I don't how easy it would be for them to switch to stmmac's DT binding.
> (Adding Stephen Warren to CC.)

I don't believe there's any issue switching drivers, so long as the new one
works on our HW. However, we can't switch DT binding since that's an ABI.
So, if we switch drivers, the "new" driver needs to support all existing
DT bindings.

FWIW, I'd recommend that we don't name the "new" driver stmmac or anything
like that. Rather, name it after the IP block so that any new user of the same
IP block will find the name they expect in the source tree, and just use it.
Renaming the "new" driver to dwc_eqos or similar might be one way to achieve
that.

-- 
nvpublic
