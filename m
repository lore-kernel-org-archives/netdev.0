From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] ucc_geth_ethtool: Fix typo
Date: Fri, 30 May 2008 22:12:26 -0400
Message-ID: <4840B40A.6040305@garzik.org>
References: <1211537487-24953-1-git-send-email-leoli@freescale.com> <1211537487-24953-2-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37077 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886AbYEaCM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:12:29 -0400
In-Reply-To: <1211537487-24953-2-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li Yang wrote:
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
>  drivers/net/ucc_geth_ethtool.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
> index 299b7f1..b84ffd8 100644
> --- a/drivers/net/ucc_geth_ethtool.c
> +++ b/drivers/net/ucc_geth_ethtool.c
> @@ -308,7 +308,7 @@ static void uec_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
>  		buf += UEC_TX_FW_STATS_LEN * ETH_GSTRING_LEN;
>  	}
>  	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX)
> -		memcpy(buf, tx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
> +		memcpy(buf, rx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
>  			       	ETH_GSTRING_LEN);

applied 1-2


