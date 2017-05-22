From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/11] qede: Fix sparse warnings
Date: Mon, 22 May 2017 12:38:04 -0400 (EDT)
Message-ID: <20170522.123804.1189830414503494485.davem@davemloft.net>
References: <1495452731-27171-1-git-send-email-Yuval.Mintz@cavium.com>
        <1495452731-27171-2-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Manish.Chopra@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935888AbdEVQiP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 12:38:15 -0400
In-Reply-To: <1495452731-27171-2-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Mon, 22 May 2017 14:32:01 +0300

> From: Manish Chopra <Manish.Chopra@cavium.com>
> 
> Signed-off-by: Manish Chopra <Manish.Chopra@cavium.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
> ---
>  drivers/net/ethernet/qlogic/qede/qede_dcbnl.c   |  1 -
>  drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 10 ++++++----
>  drivers/net/ethernet/qlogic/qede/qede_fp.c      | 25 ++++++++++++++-----------
>  drivers/net/ethernet/qlogic/qede/qede_roce.c    |  4 ++--
>  4 files changed, 22 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c b/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
> index a9e7379..6e7747b 100644
> --- a/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
> +++ b/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
> @@ -313,7 +313,6 @@ static int qede_dcbnl_ieee_peer_getets(struct net_device *netdev,
>  	.ieee_setets = qede_dcbnl_ieee_setets,
>  	.ieee_getapp = qede_dcbnl_ieee_getapp,
>  	.ieee_setapp = qede_dcbnl_ieee_setapp,
> -	.getdcbx = qede_dcbnl_getdcbx,
>  	.ieee_peer_getpfc = qede_dcbnl_ieee_peer_getpfc,
>  	.ieee_peer_getets = qede_dcbnl_ieee_peer_getets,
>  	.getstate = qede_dcbnl_getstate,

Please.

This is exactly the problem when such a terse commit message, or lack
of any message at all as is the case here, occurs.

I have no idea what removing this method assignment has to do with
fixing sparse warnings.
