From: Suman Tripathi <stripathi@apm.com>
Subject: Re: [PATCH net-next v1 1/1] drivers: net: xgene: Fix the compilation
 error "error: implicit declaration of function 'acpi_evaluate_integer'" in
 APM X-Gene ethernet driver.
Date: Wed, 1 Jul 2015 12:33:20 +0530
Message-ID: <CAOHikRDY1dx4DiDD_Lny228t+sQdmUiu_NmTGoPS_Y6NPXNRLg@mail.gmail.com>
References: <1435134100-12460-1-git-send-email-stripathi@apm.com>
	<1435134100-12460-2-git-send-email-stripathi@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	Keyur Chudgar <kchudgar@apm.com>, patches <patches@apm.com>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Suman Tripathi <stripathi@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34954 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbbGAHDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 03:03:21 -0400
Received: by wgjx7 with SMTP id x7so28065679wgj.2
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 00:03:20 -0700 (PDT)
In-Reply-To: <1435134100-12460-2-git-send-email-stripathi@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi ,

Any comments on this patch .

On Wed, Jun 24, 2015 at 1:51 PM, Suman Tripathi <stripathi@apm.com> wrote:
> This patch guards the acpi_evaluate_interger function as it fails
> the build for NON_ACPI CONFIG.
>
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Signed-off-by: Suman Tripathi <stripathi@apm.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index 4e83d4c..70b9ef6 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -871,6 +871,7 @@ static const struct net_device_ops xgene_ndev_ops = {
>         .ndo_set_mac_address = xgene_enet_set_mac_address,
>  };
>
> +#ifdef CONFIG_ACPI
>  static int xgene_get_port_id_acpi(struct device *dev,
>                                   struct xgene_enet_pdata *pdata)
>  {
> @@ -886,6 +887,7 @@ static int xgene_get_port_id_acpi(struct device *dev,
>
>         return 0;
>  }
> +#endif
>
>  static int xgene_get_port_id_dt(struct device *dev, struct xgene_enet_pdata *pdata)
>  {
> --
> 1.8.2.1
>



-- 
Thanks,
with regards,
Suman Tripathi
