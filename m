From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: enable tx queue 0 for gmac4 IPs
 synthesized with multiple TX queues
Date: Mon, 28 Nov 2016 11:29:21 -0500 (EST)
Message-ID: <20161128.112921.631621178188973017.davem@davemloft.net>
References: <1479998194-7113-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, niklass@axis.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: niklas.cassel@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32870 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932930AbcK1Qjh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 11:39:37 -0500
In-Reply-To: <1479998194-7113-1-git-send-email-niklass@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Thu, 24 Nov 2016 15:36:33 +0100

> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> The dwmac4 IP can synthesized with 1-8 number of tx queues.
> On an IP synthesized with DWC_EQOS_NUM_TXQ > 1, all txqueues are disabled
> by default. For these IPs, the bitfield TXQEN is R/W.
> 
> Always enable tx queue 0. The write will have no effect on IPs synthesized
> with DWC_EQOS_NUM_TXQ == 1.
> 
> The driver does still not utilize more than one tx queue in the IP.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Alexandre, we are still waiting for your implicit/explicit ACK on this
change.

Thank you.
