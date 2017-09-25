From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmsmac: make const array ucode_ofdm_rates static,
 reduces object code size
Date: Mon, 25 Sep 2017 08:23:34 +0000 (UTC)
Message-ID: <20170925082334.DB0A860618@smtp.codeaurora.org>
References: <20170922140316.12768-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Chi-Hsien Lin <chi-hsien.lin@cypress.com>,
        Wright Feng <wright.feng@cypress.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com,
        brcm80211-dev-list@cypress.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922140316.12768-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate const array ucode_ofdm_rates on the stack, instead make it
> static. Makes the object code smaller by 100 bytes:
> 
> Before:
>    text	   data	    bss	    dec	    hex	filename
>   39482	    564	      0	  40046	   9c6e	phy_cmn.o
> 
> After
>    text	   data	    bss	    dec	    hex	filename
>   39326	    620	      0	  39946	   9c0a	phy_cmn.o
> 
> (gcc 6.3.0, x86-64)
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>

Patch applied to wireless-drivers-next.git, thanks.

d5633bb2c62a brcmsmac: make const array ucode_ofdm_rates static, reduces object code size

-- 
https://patchwork.kernel.org/patch/9966221/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
