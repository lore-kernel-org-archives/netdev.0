From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: [PATCH 13/15] stmmac: use IS_ENABLED() instead of checking for
 built-in or module
Date: Mon, 12 Sep 2016 18:47:40 +0200
Message-ID: <747e1ae3-80cf-dfa7-613a-c3f8821ad2af@st.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
 <1473689026-6983-14-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>,
        <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:51951 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751672AbcILQrr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 12:47:47 -0400
In-Reply-To: <1473689026-6983-14-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Javier,

On 09/12/2016 04:03 PM, Javier Martinez Canillas wrote:
> The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
> built-in or as a module, use that macro instead of open coding the same.
>
> Using the macro makes the code more readable by helping abstract away some
> of the Kconfig built-in and module enable details.
>
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
> ---
>
>  drivers/net/ethernet/stmicro/stmmac/common.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index 2533b91f1421..d3292c4a6eda 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -30,7 +30,7 @@
>  #include <linux/stmmac.h>
>  #include <linux/phy.h>
>  #include <linux/module.h>
> -#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> +#if IS_ENABLED(CONFIG_VLAN_8021Q)
>  #define STMMAC_VLAN_TAG_USED
>  #include <linux/if_vlan.h>
>  #endif
>

Reviewed-by: Alexandre TORGUE <alexandre.torgue@st.com>

Thanks,

Alex
