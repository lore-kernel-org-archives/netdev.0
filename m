From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 16/17] net: stmmac: remove unused variable in
 sysfs_display_ring
Date: Tue, 31 Jan 2017 11:11:15 +0100
Message-ID: <cfa9fc16-b403-d9b0-ab6c-2f28dbd0b5dc@st.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-17-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:55457 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751856AbdAaKLj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 05:11:39 -0500
In-Reply-To: <20170131091152.13842-17-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> The u64 x variable in sysfs_display_ring is unused.
> This patch remove it.
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>


well spot

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>


> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 ---
>  1 file changed, 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index b494bc2..f0ce780 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2890,9 +2890,7 @@ static void sysfs_display_ring(void *head, int size, int extend_desc,
>  	struct dma_desc *p = (struct dma_desc *)head;
>
>  	for (i = 0; i < size; i++) {
> -		u64 x;
>  		if (extend_desc) {
> -			x = *(u64 *) ep;
>  			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
>  				   i, (unsigned int)virt_to_phys(ep),
>  				   le32_to_cpu(ep->basic.des0),
> @@ -2901,7 +2899,6 @@ static void sysfs_display_ring(void *head, int size, int extend_desc,
>  				   le32_to_cpu(ep->basic.des3));
>  			ep++;
>  		} else {
> -			x = *(u64 *) p;
>  			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
>  				   i, (unsigned int)virt_to_phys(ep),
>  				   le32_to_cpu(p->des0), le32_to_cpu(p->des1),
>
