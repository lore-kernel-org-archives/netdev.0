From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: stmmac: Restore DT backwards-compatibility
Date: Wed, 22 Mar 2017 12:15:43 -0700 (PDT)
Message-ID: <20170322.121543.312482663442228207.davem@davemloft.net>
References: <20170321151211.31841-1-thierry.reding@gmail.com>
        <20170321151211.31841-2-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        Joao.Pinto@synopsys.com, clabbe.montjoie@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thierry.reding@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43370 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936056AbdCVTPp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 15:15:45 -0400
In-Reply-To: <20170321151211.31841-2-thierry.reding@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Reding <thierry.reding@gmail.com>
Date: Tue, 21 Mar 2017 16:12:10 +0100

> From: Thierry Reding <treding@nvidia.com>
> 
> Recent changes to support multiple queues in the device tree bindings
> resulted in the number of RX and TX queues to be initialized to zero for
> device trees not adhering to the new bindings.
> 
> Restore backwards-compatibility with those device trees by falling back
> to a single RX and TX queues each.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>

Applied to net-next
