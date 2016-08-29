From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH v2] fix:brcmfmac: add missing header dependencies
Date: Mon, 29 Aug 2016 09:59:46 +0200
Message-ID: <6e8b16f5-b4c7-39eb-dad4-d7fb3c08667f@broadcom.com>
References: <1472278103-28320-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@linaro.org,
        xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>, franky.lin@broadcom.com,
        hante.meuleman@broadcom.com, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472278103-28320-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27-8-2016 8:08, Baoyou Xie wrote:
> We get 1 warning when biuld kernel with W=1:
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c:23:6: warning: no previous prototype for '__brcmf_err' [-Wmissing-
> prototypes]
> 
> In fact, this function is declared in brcmfmac/debug.h, so this patch
> add missing header dependencies

Thanks for this fix, but please remove the 'fix:' prefix in the subject
as it just noise.

Regards,
Arend

> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
> ---
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c
> index a10f35c..fe67559 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c
> @@ -19,6 +19,7 @@
>  #ifndef __CHECKER__
>  #define CREATE_TRACE_POINTS
>  #include "tracepoint.h"
> +#include "debug.h"
>  
>  void __brcmf_err(const char *func, const char *fmt, ...)
>  {
> 
