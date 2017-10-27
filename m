From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: Re: [PATCH net-next 2/2] bindings: net: stmmac: Add documentation for
 TSN parameters
Date: Fri, 27 Oct 2017 10:05:17 +0100
Message-ID: <e14b8b79-465b-9cf3-4ecc-52de4781d9c0@synopsys.com>
References: <cover.1508938927.git.joabreu@synopsys.com>
 <ef1d220cf792c74ae278e0200ca4763f9ab62d3e.1508938927.git.joabreu@synopsys.com>
 <c2a4a435-0b0b-4fa3-a69a-280f6d0c6427@gmail.com>
 <23152048-09fe-2950-e1ff-8cf90ca3f465@synopsys.com>
 <20171026090308.GD20299@lunn.ch>
 <867d6d43-9df7-4097-db5a-f2049236394f@synopsys.com>
 <20171026215629.GB8489@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Rob Herring <robh+dt@kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:59711 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdJ0JFY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 05:05:24 -0400
In-Reply-To: <20171026215629.GB8489@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 26-10-2017 22:56, Andrew Lunn wrote:
>> About my patches, what I think would be better now would be to
>> drop the configuration by DT and integrate the remaining
>> configuration, letting the EST parameters be populated by SoC
>> specific wrappers.
> Hi Jose
>
> The problem with SoC specific wrappers is that you are going to have
> to remove them once the real interface is defined. Anybody who uses
> your SoC specific wrappers is going to have to re-write their code,
> when it all gets ripped out.

Yeah, I agree. But what about just merge the implementation and
then construct the interface? I mean just creating the internal
parameters in stmmac and then the configuration functions.

>
> You generally don't add device SoC specific wrappers. Imagine if
> everybody did that. Lots of different ways of doing the same thing.
> My suggesting is to keep your patches out for the moment, waiting for
> generic support to be added.

I think we should take advantage of the fact that this is working
and ready to be merged. Its just HW configuration but maybe it
can serve as momentum for other drivers to also integrate this?

Best Regards,
Jose Miguel Abreu

>
>      Andrew
