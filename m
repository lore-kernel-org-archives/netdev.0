From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Thu, 12 Jan 2017 15:39:47 +0000
Message-ID: <3ec17612-255f-5fc7-02c6-9ba5b76d2c09@synopsys.com>
References: <a2d2e457-47e5-bb73-a059-0cb907a29ae0@synopsys.com>
 <57d96ccb-7fd4-0707-4902-a5bdd2a6ef39@st.com>
 <dbb59d07-4ab4-37d2-5e70-073091749445@synopsys.com>
 <20170112.102630.1448382649844350511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <alexandre.torgue@st.com>, <f.fainelli@gmail.com>,
        <lars.persson@axis.com>, <niklass@axis.com>,
        <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:58201 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdALPj4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:39:56 -0500
In-Reply-To: <20170112.102630.1448382649844350511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 3:26 PM de 1/12/2017, David Miller escreveu:
> 
> I don't understand at all why it is so important to change the name of
> these files nor the directory they live in.

GMAC4 is a nickname for the Designware Ethernet QoS, which began in version 4.x
for historical reasons. Soon, we will have version eQOS 5.x version release and
we will have some features in stmmac only available from version 5.x. If the
dwmac4* files and functions were called eqos it would clearer and easier to
include the 5.x stuff.

> 
> What bonafide benefit will users receive if we do this?

>From my point of view have a /net/ethernet/dwc/stmmac instead of a
/net/ethernet/stmicro/stmmac will be clearer for users that it is the spot for
Ethernet Designware IPs. This change will not cause any problems. We are going o
have new Synopsys Ethernet IPs with new drivers that would be placed inside this
/net/ethernet/dwc/. In my understanding the advantage is to prepare the future.
Imagine that I am developing a new driver for a new Ethernet IP. So I work at
Synopsys, I am developing a driver for Ethernet EXAMPLE IP. Where would put it?
This is my concern to the future.

> 
> The only clear part is the downside, which is that it is going to make
> it painful to browse source history and backport bug fixes.
> 
> Please, let's not do this.
> 
> Thanks.
> 

Thanks,
Joao
