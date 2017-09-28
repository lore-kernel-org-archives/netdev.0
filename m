From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: dwmac4: Re-enable MAC Rx before powering
 down
Date: Thu, 28 Sep 2017 10:19:26 -0700 (PDT)
Message-ID: <20170928.101926.1703367660107401038.davem@davemloft.net>
References: <1506422693-26144-1-git-send-email-ed.blake@sondrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: ed.blake@sondrel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49696 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751339AbdI1RT1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:19:27 -0400
In-Reply-To: <1506422693-26144-1-git-send-email-ed.blake@sondrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ed Blake <ed.blake@sondrel.com>
Date: Tue, 26 Sep 2017 11:44:53 +0100

> Re-enable the MAC receiver by setting CONFIG_RE before powering down,
> as instructed in section 6.3.5.1 of [1].  Without this the MAC fails
> to receive WoL packets and never wakes up.
> 
> [1] DWC Ethernet QoS Databook 4.10a October 2014
> 
> Signed-off-by: Ed Blake <ed.blake@sondrel.com>

Applied.
