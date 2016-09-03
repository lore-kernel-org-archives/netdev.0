From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v4] brcmfmac: add missing header dependencies
Date: Sat,  3 Sep 2016 10:10:35 +0000 (UTC)
Message-ID: <20160903101035.74BDC6201D@smtp.codeaurora.org>
References: <1472474375-29910-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: arend.vanspriel@broadcom.com, franky.lin@broadcom.com,
        hante.meuleman@broadcom.com, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, baoyou.xie@linaro.org,
        xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472474375-29910-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Baoyou Xie <baoyou.xie@linaro.org> wrote:
> We get 1 warning when building kernel with W=1:
> 
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c:23:6: warning: no previous prototype for '__brcmf_err' [-Wmissing-prototypes]
> 
> In fact, this function is declared in brcmfmac/debug.h, so this patch
> adds missing header dependencies.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Thanks, 1 patch applied to wireless-drivers-next.git:

8af92af3f2d5 brcmfmac: add missing header dependencies

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9303939/
