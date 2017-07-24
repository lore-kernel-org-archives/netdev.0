From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Adjust dump offset of DMA registers for
 ethtool
Date: Mon, 24 Jul 2017 16:20:34 -0700 (PDT)
Message-ID: <20170724.162034.889991896401207028.davem@davemloft.net>
References: <1500672909-24408-1-git-send-email-thor.thayer@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: thor.thayer@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755386AbdGXXUf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 19:20:35 -0400
In-Reply-To: <1500672909-24408-1-git-send-email-thor.thayer@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: thor.thayer@linux.intel.com
Date: Fri, 21 Jul 2017 16:35:09 -0500

> From: Thor Thayer <thor.thayer@linux.intel.com>
> 
> The commit fbf68229ffe7 ("net: stmmac: unify registers dumps methods")
> 
> in the Linux kernel modified the register dump to store the DMA registers
> at the DMA register offset (0x1000) but ethtool (stmmac.c) looks for the
> DMA registers after the MAC registers which is offset 55.
> This patch copies the DMA registers from the higher offset to the offset
> where ethtool expects them.
> 
> Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>

Applied.
