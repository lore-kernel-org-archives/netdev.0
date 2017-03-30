From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH] [net-next] stmmac: use netif_set_real_num_{rx,tx}_queues
Date: Thu, 30 Mar 2017 09:45:36 +0200
Message-ID: <20170330074536.GA4814@Red>
References: <20170328094856.3457886-1-arnd@arndb.de>
 <20170328.180105.1996071259325891752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arnd@arndb.de, peppe.cavallaro@st.com, alexandre.torgue@st.com,
        Joao.Pinto@synopsys.com, treding@nvidia.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36410 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932555AbdC3Hpn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 03:45:43 -0400
Content-Disposition: inline
In-Reply-To: <20170328.180105.1996071259325891752.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 06:01:05PM -0700, David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Tue, 28 Mar 2017 11:48:21 +0200
> 
> > A driver must not access the two fields directly but should instead use
> > the helper functions to set the values and keep a consistent internal
> > state:
> > 
> > ethernet/stmicro/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
> > ethernet/stmicro/stmmac/stmmac_main.c:4083:8: error: 'struct net_device' has no member named 'real_num_rx_queues'; did you mean 'real_num_tx_queues'?
> > 
> > Fixes: a8f5102af2a7 ("net: stmmac: TX and RX queue priority configuration")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> Applied.

This break my revert patch. (since it patch ("net: stmmac: enable multiple buffers").
Since dwmac-sunxi is still broken, what can I do ? send two revert patch ? or adapt the reverting patch.
