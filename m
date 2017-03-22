From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: stmmac: Use AVB mode by default
Date: Wed, 22 Mar 2017 12:15:49 -0700 (PDT)
Message-ID: <20170322.121549.1868169036390423353.davem@davemloft.net>
References: <20170321151211.31841-1-thierry.reding@gmail.com>
        <20170321151211.31841-3-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        Joao.Pinto@synopsys.com, clabbe.montjoie@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thierry.reding@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43380 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936062AbdCVTPv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 15:15:51 -0400
In-Reply-To: <20170321151211.31841-3-thierry.reding@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Reding <thierry.reding@gmail.com>
Date: Tue, 21 Mar 2017 16:12:11 +0100

> From: Thierry Reding <treding@nvidia.com>
> 
> Prior to the recent multi-queue changes the driver would configure the
> queues to use the AVB mode, but the mode then got switched to DCB. The
> hardware still works fine in DCB mode, but my testing capabilities are
> limited, so it's safer to revert to the prior setting anyway.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>

Applied to net-next
