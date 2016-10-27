From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Thu, 27 Oct 2016 16:05:50 -0400 (EDT)
Message-ID: <20161027.160550.462315166736329395.davem@davemloft.net>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
        <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, timur@codeaurora.org, andrew@lunn.ch,
        f.fainelli@gmail.com
To: zefir.kurtisi@neratec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33388 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754557AbcJ0UF4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 16:05:56 -0400
In-Reply-To: <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Date: Mon, 24 Oct 2016 12:40:54 +0200

> In SGMII mode, we observed an autonegotiation issue
> after power-down-up cycles where the copper side
> reports successful link establishment but the
> SGMII side's link is down.
> 
> This happened in a setup where the at8031 is
> connected over SGMII to a eTSEC (fsl gianfar),
> but so far could not be reproduced with other
> Ethernet device / driver combinations.
> 
> This commit adds a wrapper function for at8031
> that in case of operating in SGMII mode double
> checks SGMII link state when generic aneg_done()
> succeeds. It prints a warning on failure but
> intentionally does not try to recover from this
> state. As a result, if you ever see a warning
> '803x_aneg_done: SGMII link is not ok' you will
> end up having an Ethernet link up but won't get
> any data through. This should not happen, if it
> does, please contact the module maintainer.
> 
> Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>

Applied.
