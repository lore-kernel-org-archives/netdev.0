From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Suggestion: Merge of sxgbe to stmmac
Date: Mon, 10 Apr 2017 14:42:59 +0100
Message-ID: <a5828934-d5fa-ae0f-4096-22f4a9395e7b@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>,
        Carlos Palminha <CARLOS.PALMINHA@synopsys.com>
To: David Miller <davem@davemloft.net>, <bh74.an@samsung.com>,
        <ks.giri@samsung.com>, <vipul.pandya@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:35537 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752877AbdDJNok (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 09:44:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Byungho, Girish and David,

Today I was requested to analyse the Synopsys XGMAC IP support in the Linux
kernel and I found AMD' xgbe and Samsung's sxgbe drivers.

Samsung' driver has the same architecture as stmmac, so I am sending this e-mail
to suggest the merge of sxgbe to stmmac.

Currently stmmac supports older cores like MAC 10/100/1000 but also one of the
latest such as eQOS. The idea would be to add XGMAC support to stmmac by
creating a dwxgmac_core.c and dwxgmac_dma.c with all XGMAC operations related to
MAC and DMA and use the common infrastructure.

This would bring many advantages like:

a) xgmac support would be available for all Synopsys XGMAC IP users
b) stmmac has a great and wide community of users that maintain it, assuring
quality and latest features availability
c) avoid replication of code and this way we can work together and achieve
better results
d) maintaince becomes easier

I would like to hear your thoughts about the subject.

Thanks,
Joao
