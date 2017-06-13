From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: Fix kernel oops on resume when request firmware fails.
Date: Tue, 13 Jun 2017 05:54:48 +0000 (UTC)
Message-ID: <20170613055448.C0CD36075B@smtp.codeaurora.org>
References: <20170523180733.26276-1-enric.balletbo@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Christian Daudt <csd@broadcom.com>
To: Enric Balletbo i Serra <enric.balletbo@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170523180733.26276-1-enric.balletbo@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enric Balletbo i Serra <enric.balletbo@collabora.com> wrote:

> When request firmware fails, brcmf_ops_sdio_remove is being called and
> brcmf_bus freed. In such circumstancies if you do a suspend/resume cycle
> the kernel hangs on resume due a NULL pointer dereference in resume
> function.
> 
> Steps to reproduce the problem:
>  - modprobe brcmfmac without the firmware
>      brcmfmac mmc1:0001:1: Direct firmware load for brcm/brcmfmac4354-sdio.bin
>      failed with error -2
>  - do a suspend/resume cycle (echo mem > /sys/power/state)
> 
> Protect against the NULL pointer derefence by checking if dev_get_drvdata
> returned a valid pointer.
> 
> Signed-off-by: Enric Balletbo i Serra <enric.balletbo@collabora.com>

My understanding is that there's a new version of this patch which fixes
the issue. If not, let me know.

Patch set to Superseded.

-- 
https://patchwork.kernel.org/patch/9743159/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
