From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v2] net: qcom/emac: add ethtool support
Date: Mon, 09 Jan 2017 12:08:08 -0500 (EST)
Message-ID: <20170109.120808.1043502787838349598.davem@davemloft.net>
References: <1483738981-31019-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, alokc@codeaurora.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42710 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbdAIRIN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:08:13 -0500
In-Reply-To: <1483738981-31019-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Fri,  6 Jan 2017 15:43:01 -0600

> Add support for some ethtool methods: get/set link settings, get/set
> message level, get statistics, get link status, get ring params, get
> pause params, and restart autonegotiation.
> 
> The code to collect the hardware statistics is moved into its own
> function so that it can be used by "get statistics" method.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
> 
> Notes:
>     I don't trust my implementation of emac_get_pauseparam.  I feel like
>     I'm missing something.
>     
>     v2: added emac_get_pauseparam and emac_get_ringparam

This doesn't apply cleanly to net-next, please respin.
