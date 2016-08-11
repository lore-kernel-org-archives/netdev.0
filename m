From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH 1/1 linux-next] net: hns: fix typo in
 g_gmac_stats_string[]
Date: Thu, 11 Aug 2016 08:45:26 +0800
Message-ID: <57ABCAA6.10006@huawei.com>
References: <1470844116-13545-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>
To: Fabian Frederick <fabf@skynet.be>,
	Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470844116-13545-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fabian,

This patch is fine to me, many thanks.

Yisen

在 2016/8/10 23:48, Fabian Frederick 写道:
> s/gamc/gmac/
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
> index 1235c7f..1e1eb92 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
> @@ -17,7 +17,7 @@ static const struct mac_stats_string g_gmac_stats_string[] = {
>  	{"gmac_rx_octets_total_ok", MAC_STATS_FIELD_OFF(rx_good_bytes)},
>  	{"gmac_rx_octets_bad", MAC_STATS_FIELD_OFF(rx_bad_bytes)},
>  	{"gmac_rx_uc_pkts", MAC_STATS_FIELD_OFF(rx_uc_pkts)},
> -	{"gamc_rx_mc_pkts", MAC_STATS_FIELD_OFF(rx_mc_pkts)},
> +	{"gmac_rx_mc_pkts", MAC_STATS_FIELD_OFF(rx_mc_pkts)},
>  	{"gmac_rx_bc_pkts", MAC_STATS_FIELD_OFF(rx_bc_pkts)},
>  	{"gmac_rx_pkts_64octets", MAC_STATS_FIELD_OFF(rx_64bytes)},
>  	{"gmac_rx_pkts_65to127", MAC_STATS_FIELD_OFF(rx_65to127)},
> 
