From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: qcom/emac: ensure that pause frames are
 enabled
Date: Wed, 09 Nov 2016 18:45:55 -0500 (EST)
Message-ID: <20161109.184555.285408341233404052.davem@davemloft.net>
References: <1478537501-23454-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, alokc@codeaurora.org, netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44626 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751157AbcKIXqB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 18:46:01 -0500
In-Reply-To: <1478537501-23454-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Mon,  7 Nov 2016 10:51:39 -0600

> The qcom emac driver experiences significant packet loss (through frame
> check sequence errors) if flow control is not enabled and the phy is
> not configured to allow pause frames to pass through it.  Therefore, we
> need to enable flow control and force the phy to pass pause frames.

Series applied, thanks.
