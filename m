From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v2] net: phy: phy drivers should not set
 SUPPORTED_[Asym_]Pause
Date: Mon, 14 Nov 2016 13:12:25 -0500 (EST)
Message-ID: <20161114.131225.1515538193536426496.davem@davemloft.net>
References: <1478821561-26498-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, jon.mason@broadcom.com,
        netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38274 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932731AbcKNSM3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 13:12:29 -0500
In-Reply-To: <1478821561-26498-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Thu, 10 Nov 2016 17:46:01 -0600

> Instead of having individual PHY drivers set the SUPPORTED_Pause and
> SUPPORTED_Asym_Pause flags, phylib itself should set those flags.
> During autonegotiation, the PHYs will determine whether to enable
> pause frame support.
> 
> Pause frames are a feature that is supported by the MAC.  It is the MAC
> that generates the frames and that processes them.  The PHY can only be
> configured to allow them to pass through.
> 
> So the new process is:
 ...
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
> 
> v2: set the Pause bits in phy_probe()
>     update broadcom.c which was recently changed

Florian please review this patch.

Thank you.
