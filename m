From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] net: qcom/emac: add ethool support for
 setting pause parameters
Date: Tue, 07 Feb 2017 13:19:35 -0500 (EST)
Message-ID: <20170207.131935.63339253886860831.davem@davemloft.net>
References: <1486416892-10927-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53452 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754199AbdBGSUI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 13:20:08 -0500
In-Reply-To: <1486416892-10927-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Mon,  6 Feb 2017 15:34:52 -0600

> To support setting the pause parameters, the driver can no longer just
> mirror the PHY.  The set_pauseparam feature allows the driver to
> force the setting in the MAC, regardless of how the PHY is configured.
> This means that we now need to maintain an internal state for pause
> frame support, and so get_pauseparam also needs to be updated.
> 
> If the interface is already running when the setting is changed, then
> the interface is reset.
> 
> Note that if the MAC is configured to enable RX pause frame support
> (i.e. it transmits pause frames to throttle the other end), but the
> PHY is configured to block those frames, then the feature will not work.
> 
> Also some buffer size initialization code into emac_init_adapter(),
> so that it lives with similar code, including the initializtion of
> pause frame support.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Looks good, applied, thanks Timur.
