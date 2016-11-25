From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 3/4] net: stmmac: dwmac-generic: add missing compatible
 strings
Date: Fri, 25 Nov 2016 09:54:40 +0100
Message-ID: <4d7e4ba0-d212-6a11-85fa-04babd7da35b@st.com>
References: <1479911104-19864-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:57783 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753985AbcKYIzU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 03:55:20 -0500
In-Reply-To: <1479911104-19864-1-git-send-email-niklass@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Niklas

On 11/23/2016 3:25 PM, Niklas Cassel wrote:
> From: Niklas Cassel <niklas.cassel@axis.com>
>
> devicetree binding for stmmac states:
> - compatible: Should be "snps,dwmac-<ip_version>", "snps,dwmac"
> 	For backwards compatibility: "st,spear600-gmac" is also supported.
>
> Since dwmac-generic.c calls stmmac_probe_config_dt explicitly,
> another alternative would have been to remove all compatible strings
> other than "snps,dwmac" and "st,spear600-gmac" from dwmac-generic.c.
>
> However, that would probably do more good than harm, since when trying
> to figure out what hardware a certain driver supports, you usually look
> at the compatible strings in the struct of_device_id, and not in some
> function defined in a completely different file.
>
> No functional change intended.
>
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
> index b1e5f24708c9..52cd365b8e5e 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
> @@ -58,9 +58,12 @@ static int dwmac_generic_probe(struct platform_device *pdev)
>
>  static const struct of_device_id dwmac_generic_match[] = {
>  	{ .compatible = "st,spear600-gmac"},
> +	{ .compatible = "snps,dwmac-3.50a"},
>  	{ .compatible = "snps,dwmac-3.610"},
>  	{ .compatible = "snps,dwmac-3.70a"},
>  	{ .compatible = "snps,dwmac-3.710"},
> +	{ .compatible = "snps,dwmac-4.00"},
> +	{ .compatible = "snps,dwmac-4.10a"},
>  	{ .compatible = "snps,dwmac"},
>  	{ }
>  };
>
