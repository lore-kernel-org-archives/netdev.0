From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 0/4 v2 net-next] net: stmmac: adding multiple buffers
Date: Fri, 7 Apr 2017 11:20:22 +0200
Message-ID: <20170407092022.GB16604@Red>
References: <cover.1491409859.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, treding@nvidia.com, niklas.cassel@axis.com,
        netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35324 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755120AbdDGJU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 05:20:27 -0400
Received: by mail-wr0-f193.google.com with SMTP id t20so18261520wra.2
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 02:20:26 -0700 (PDT)
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

For whole serie,
Tested-by: Corentin Labbe <clabbe.montjoie@gmail.com>
