From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] [trivial] stmmac: Fix typo in stmmac_pci.c
Date: Wed, 08 Feb 2012 14:54:00 +0100
Message-ID: <4F327E78.2040207@st.com>
References: <1328702901-2157-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: Masanari Iida <standby24x7@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328702901-2157-1-git-send-email-standby24x7@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Masanari.

Peppe

On 2/8/2012 1:08 PM, Masanari Iida wrote:
> Correct spelling "regiser" to "register" in
> drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index c796de9..6ce0706 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -85,7 +85,7 @@ static int __devinit stmmac_pci_probe(struct pci_dev *pdev,
>  			continue;
>  		addr = pci_iomap(pdev, i, 0);
>  		if (addr == NULL) {
> -			pr_err("%s: ERROR: cannot map regiser memory, aborting",
> +			pr_err("%s: ERROR: cannot map register memory, aborting",
>  			       __func__);
>  			ret = -EIO;
>  			goto err_out_map_failed;
