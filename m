From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: qtnfmac: Tidy up DMA mask setting
Date: Thu,  3 Aug 2017 10:01:08 +0000 (UTC)
Message-ID: <20170803100110.A8D2D6087E@smtp.codeaurora.org>
References: <2c3f47792b2e38d5584d641d98e82f8318fefc72.1500917445.git.robin.murphy@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: imitsyanko@quantenna.com, avinashp@quantenna.com,
        smatyukevich@quantenna.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Robin Murphy <robin.murphy@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2c3f47792b2e38d5584d641d98e82f8318fefc72.1500917445.git.robin.murphy@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robin Murphy <robin.murphy@arm.com> wrote:

> As the only caller of dma_supported() outside of DMA API internals, the
> qtfnmac driver stands out and invites scrutiny. Thankfully, it's not
> being used for evil, but it is entirely redundant, since it open-codes a
> check that the DMA mask setting functions are going to perform anyway.
> In fact, the whole qtnf_pcie_init_dma_mask() function is nothing more
> than a rather long-winded implementation of dma_set_mask_and_coherent(),
> so let's just use that directly.
> 
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
> Acked-by: Sergey Matyukevich <sergey.matyukevich.os@quantenna.com>

Patch applied to wireless-drivers-next.git, thanks.

13cb8a5845ff qtnfmac: Tidy up DMA mask setting

-- 
https://patchwork.kernel.org/patch/9859961/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
