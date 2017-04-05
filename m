From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 0/4 v2 net-next] net: stmmac: adding multiple buffers
Date: Wed, 5 Apr 2017 18:59:41 +0200
Message-ID: <20170405165941.GA18568@Red>
References: <cover.1491409859.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, treding@nvidia.com, niklas.cassel@axis.com,
        netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33720 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933058AbdDEQ7t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 12:59:49 -0400
Received: by mail-wr0-f196.google.com with SMTP id g19so4408807wrb.0
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 09:59:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1491409859.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 05, 2017 at 05:43:00PM +0100, Joao Pinto wrote:
> This patch adds multiple buffers to stmmac in a more fragmented
> way, in order to make problem debug easier.
> 
> I would kindly request to people to test this patch in their HWs in
> order to check if everything's functional. Thank you.
> 
> Joao Pinto (4):
>   net: stmmac: break some functions into RX and TX scopes
>   net: stmmac: adding multiple buffers for RX
>   net: stmmac: adding multiple buffers for TX
>   net: stmmac: adding multiple napi mechanism
> 
>  drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |   45 +-
>  drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |   46 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   49 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 1257 ++++++++++++++-------
>  4 files changed, 947 insertions(+), 450 deletions(-)
> 
> -- 
> 2.9.3
> 

Hello

I have tested v1 and didn't hit any issue on dwmac-sunxi/dwmac-sun8i.
I will test the v2 and send just after my tested-by

Regards
