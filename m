From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 2/2] ethtool: stmmac: Add DMA HW Feature Register
Date: Wed, 28 Jun 2017 11:03:23 +0200
Message-ID: <12583b41-540b-c0a9-4dfe-874d8d46709a@st.com>
References: <1498600275-22334-1-git-send-email-thor.thayer@linux.intel.com>
 <1498600275-22334-3-git-send-email-thor.thayer@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <thor.thayer@linux.intel.com>, <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:34117 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751910AbdF1JWE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 05:22:04 -0400
In-Reply-To: <1498600275-22334-3-git-send-email-thor.thayer@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/27/2017 11:51 PM, thor.thayer@linux.intel.com wrote:
> From: Thor Thayer <thor.thayer@linux.intel.com>
>
> This patch adds the DMA HW Feature Register which is at the end
> of the DMA registers and is documented in Version 3.70a.
>
> Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>
> ---
>   stmmac.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/stmmac.c b/stmmac.c
> index e1bb291..7d7bebd 100644
> --- a/stmmac.c
> +++ b/stmmac.c
> @@ -64,7 +64,7 @@ int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
>   	fprintf(stdout, "\n");
>   	fprintf(stdout, "DMA Registers\n");
>   	stmmac_reg = (unsigned int *)regs->data + DMA_REG_OFFSET;
> -	for (i = 0; i < 22; i++)
> +	for (i = 0; i < 23; i++)

thx Thor for these changes, I wonder if you could add a macro instead 23 
while doing this kind of changes

Sorry if I didn't it in the past.

the, you can send the series with my Acked-by: Giuseppe Cavallaro 
<peppe.cavallaro@st.com>

Regards

peppe


>   		fprintf(stdout, "Reg%d  0x%08X\n", i, *stmmac_reg++);
>   
>   	return 0;
