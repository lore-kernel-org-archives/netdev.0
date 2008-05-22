From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ucc_geth_ethtool: Fix typo
Date: Thu, 22 May 2008 14:06:20 -0400
Message-ID: <4835B61C.4040006@garzik.org>
References: <1209470569-31270-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Yang <LeoLi@freescale.com>, Netdev <netdev@vger.kernel.org>
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35095 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755727AbYEVSGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 14:06:25 -0400
In-Reply-To: <1209470569-31270-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
>  drivers/net/ucc_geth_ethtool.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
> index 9a9622c..a995a3a 100644
> --- a/drivers/net/ucc_geth_ethtool.c
> +++ b/drivers/net/ucc_geth_ethtool.c
> @@ -314,7 +314,7 @@ static void uec_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
>  		buf += UEC_TX_FW_STATS_LEN * ETH_GSTRING_LEN;
>  	}
>  	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX)
> -		memcpy(buf, tx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
> +		memcpy(buf, rx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
>  			       	ETH_GSTRING_LEN);

still looking for maintainer's ack...  seems fairly obvious to me


