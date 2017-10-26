From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] bindings: net: stmmac: Add documentation
 for TSN parameters
Date: Thu, 26 Oct 2017 11:03:08 +0200
Message-ID: <20171026090308.GD20299@lunn.ch>
References: <cover.1508938927.git.joabreu@synopsys.com>
 <ef1d220cf792c74ae278e0200ca4763f9ab62d3e.1508938927.git.joabreu@synopsys.com>
 <c2a4a435-0b0b-4fa3-a69a-280f6d0c6427@gmail.com>
 <23152048-09fe-2950-e1ff-8cf90ca3f465@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Rob Herring <robh+dt@kernel.org>
To: Jose Abreu <Jose.Abreu@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:58416 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751027AbdJZJDL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 05:03:11 -0400
Content-Disposition: inline
In-Reply-To: <23152048-09fe-2950-e1ff-8cf90ca3f465@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> These parameters may also need to change in runtime depending on
> the scheduled traffic. Unfortunately, net subsystem does not yet
> support TSN so this will have to wait and for now we will use
> fixed parameters.

Hi Jose

what you should do is help Linux get support for TSN. Please take part
in this discussion:

https://patchwork.ozlabs.org/cover/808504/

Test the RFC, make sure the concepts will work for your hardware. Make
you hardware work with these RFC patches. Help drive TSN forward. Once
the core TSN code lands, then you can post patches for your driver.

    Andrew
