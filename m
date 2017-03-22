From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: stmmac: fix dma operation mode config
 for older versions
Date: Wed, 22 Mar 2017 15:35:26 -0700 (PDT)
Message-ID: <20170322.153526.1732529873991893898.davem@davemloft.net>
References: <3b8aeab69d2987db68c74f48a3ac13c7241e1542.1490183441.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        clabbe.montjoie@gmail.com, thierry.reding@gmail.com,
        sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751738AbdCVWfa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 18:35:30 -0400
In-Reply-To: <3b8aeab69d2987db68c74f48a3ac13c7241e1542.1490183441.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Wed, 22 Mar 2017 11:56:05 +0000

> The dma operation mode configuration routine was wrongly moved to a
> function (stmmac_mtl_configuration) that is only executed if the
> core version is >= 4.00.
> 
> Fixes: 6deee2221e11 ("net: stmmac: prepare dma op mode config for multiple queues")
> Reported-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> Reviewed-by: Thierry Reding <thierry.reding@gmail.com>
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
> changes v2->v3:
> - Commit ID and title should be under a 'Fixes' tag
> changes v1->v2:
> - commit id did not have 12 digits

Applied, thanks.
