From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 09/17] net: stmmac: replace ENOSYS by EINVAL
Date: Tue, 31 Jan 2017 11:06:10 +0100
Message-ID: <abd88400-1fe0-533f-1a14-53a5979e410a@st.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-10-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:37369 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751317AbdAaKGX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 05:06:23 -0500
In-Reply-To: <20170131091152.13842-10-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> As said by checkpatch ENOSYS means 'invalid syscall nr' and nothing
> else.
> This patch replace ENOSYS by the more appropriate value EINVAL.
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index eff6282..485b1cd 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -353,7 +353,7 @@ void stmmac_remove_config_dt(struct platform_device *pdev,
>  struct plat_stmmacenet_data *
>  stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
>  {
> -	return ERR_PTR(-ENOSYS);
> +	return ERR_PTR(-EINVAL);
>  }
>
>  void stmmac_remove_config_dt(struct platform_device *pdev,
>
