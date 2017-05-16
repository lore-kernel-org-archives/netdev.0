From: Niklas Cassel <niklas.cassel@axis.com>
Subject: stmmac dtc warnings 4.12-rc1
Date: Tue, 16 May 2017 09:46:30 +0200
Message-ID: <34b0f7c7-6cec-c419-da96-7d3b197712ca@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <devicetree@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Thierry Reding <treding@nvidia.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Rob Herring <robh+dt@kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:54619 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751433AbdEPHqe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 03:46:34 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello


With the dtc in linux 4.12-rc1 we get the following
warning when compiling our stmmac node:

Warning (simple_bus_reg): Node /amba/stmmac-axi-config missing or empty reg/ranges property

Note that we do follow the example binding for stmmac:
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/devicetree/bindings/net/stmmac.txt

The binding does not specify a reg/ranges property for the stmmac-axi-config node.
(Neither does the mtl_rx_setup/mtl_tx_setup nodes.)

We are building with a local patch for dtc that fails on warnings (like -Werror).
However, I figure that there shouldn't be any warnings when compiling a dtc,
so what's the best solution here?
Add a reg = <0> property to the stmmac-axi-config/mtl_rx_setup/mtl_tx_setup nodes?


Regards,
Niklas
