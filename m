From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
Date: Mon, 12 Jan 2015 17:06:52 +0300
Message-ID: <54B3D4FC.1090806@cogentembedded.com>
References: <54B36C88.3030609@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>, brudley@broadcom.com,
	"arend@broadcom.com >> Arend van Spriel" <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>, meuleman@broadcom.com,
	kvalo@codeaurora.org, linville@tuxdriver.com,
	pieterpg@broadcom.com, hdegoede@redhat.com, wens@csie.org,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54B36C88.3030609@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 1/12/2015 9:41 AM, Fu, Zhonghui wrote:

>  From 8685c3c2746b4275fc808d9db23c364b2f54b52a Mon Sep 17 00:00:00 2001
> From: Zhonghui Fu <zhonghui.fu@linux.intel.com>
> Date: Mon, 12 Jan 2015 14:25:46 +0800
> Subject: [PATCH] brcmfmac: avoid duplicated suspend/resume operation

    The lines above are not needed.

> WiFi chip has 2 SDIO functions, and PM core will trigger
> twice suspend/resume operations for one WiFi chip to do
> the same things. This patch avoid this case.

> Acked-by: Arend van Spriel<arend@broadcom.com>
> Acked-by: Sergei Shtylyov<sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Zhonghui Fu <zhonghui.fu@linux.intel.com>
> ---
>   drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |   21 +++++++++++++++++----
>   1 files changed, 17 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> index 9880dae..8f71485 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> @@ -1070,7 +1070,7 @@ static int brcmf_ops_sdio_probe(struct sdio_func *func,
>   	 */
>   	if ((sdio_get_host_pm_caps(sdiodev->func[1]) & MMC_PM_KEEP_POWER) &&
>   	    ((sdio_get_host_pm_caps(sdiodev->func[1]) & MMC_PM_WAKE_SDIO_IRQ) ||
> -	     (sdiodev->pdata && sdiodev->pdata->oob_irq_supported)))
> +	     (sdiodev->pdata->oob_irq_supported)))

    Inner parens not needed on this line.

[...]

WBR, Sergei
