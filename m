From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH] amd-xgbe: Rename MAX_DMA_CHANNELS to avoid powerpc conflict
Date: Tue, 10 Jun 2014 08:07:27 -0500
Message-ID: <5397030F.3000704@amd.com>
References: <20140609141931.30639.72028.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <fengguang.wu@intel.com>, <kbuild-all@01.org>, <jet.chen@intel.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0140.outbound.protection.outlook.com ([207.46.163.140]:58849
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750945AbaFJNHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 09:07:38 -0400
In-Reply-To: <20140609141931.30639.72028.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

I forgot to include net-next in the email summary for this patch.
Let me know if you'd like me to re-submit it with the proper tree
specified.  I'll be sure to include it in the future.

Thanks,
Tom

On 06/09/2014 09:19 AM, Tom Lendacky wrote:
> MAX_DMA_CHANNELS is defined in asm/scatterlist.h of the powerpc
> architecture.  Rename this #define in xgbe.h to avoid the
> redefined warning issued during compilation.
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>   drivers/net/ethernet/amd/xgbe/xgbe-main.c |    2 +-
>   drivers/net/ethernet/amd/xgbe/xgbe.h      |    2 +-
>   2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> index b21f9b9..c83584a 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
> @@ -230,7 +230,7 @@ static int xgbe_probe(struct platform_device *pdev)
>   	DBGPR("--> xgbe_probe\n");
>
>   	netdev = alloc_etherdev_mq(sizeof(struct xgbe_prv_data),
> -				   MAX_DMA_CHANNELS);
> +				   XGBE_MAX_DMA_CHANNELS);
>   	if (!netdev) {
>   		dev_err(dev, "alloc_etherdev failed\n");
>   		ret = -ENOMEM;
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
> index 9a5bfe6..ab06271 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe.h
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
> @@ -138,7 +138,7 @@
>   #define RX_MIN_BUF_SIZE		(ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
>   #define RX_BUF_ALIGN		64
>
> -#define MAX_DMA_CHANNELS	16
> +#define XGBE_MAX_DMA_CHANNELS	16
>   #define DMA_ARDOMAIN_SETTING	0x2
>   #define DMA_ARCACHE_SETTING	0xb
>   #define DMA_AWDOMAIN_SETTING	0x2
>
