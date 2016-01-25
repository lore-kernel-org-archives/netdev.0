From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] brcmfmac: sdio: Increase the default timeouts a bit
Date: Mon, 25 Jan 2016 22:06:35 +1100
Message-ID: <CAGRGNgXWE=b52Mcy8NsKBZS_4gz-TUiuFipjsuTZh1xjja=uUg@mail.gmail.com>
References: <1453718849-3508-1-git-send-email-sjoerd.simons@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Paul Stewart <pstew@chromium.org>,
	Doug Anderson <dianders@chromium.org>,
	linux-rockchip@lists.infradead.org,
	Arend van Spriel <arend@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	brcm80211-dev-list@broadcom.com,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hante Meuleman <meuleman@broadcom.com>,
	Brett Rudley <brudley@broadcom.com>,
	netdev <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36042 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755368AbcAYLGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 06:06:55 -0500
In-Reply-To: <1453718849-3508-1-git-send-email-sjoerd.simons@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjoerd,

On Mon, Jan 25, 2016 at 9:47 PM, Sjoerd Simons
<sjoerd.simons@collabora.co.uk> wrote:
> On a Radxa Rock2 board with a Ampak AP6335 (Broadcom 4339 core) it seems
> the card responds very quickly most of the time, unfortunately during
> initialisation it sometimes seems to take just a bit over 2 seconds to
> respond.
>
> This results intialization failing with message like:
>   brcmf_c_preinit_dcmds: Retreiving cur_etheraddr failed, -52
>   brcmf_bus_start: failed: -52
>   brcmf_sdio_firmware_callback: dongle is not responding
>
> Increasing the timeout to allow for a bit more headroom allows the
> card to initialize reliably.
>
> A quick search online after diagnosing/fixing this showed that Google
> has a similar patch in their ChromeOS tree, so this doesn't seem
> specific to the board I'm using.
>
> Signed-off-by: Sjoerd Simons <sjoerd.simons@collabora.co.uk>

Looks sane to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
> index dd66143..75ac4bd 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
> @@ -45,8 +45,8 @@
>  #include "chip.h"
>  #include "firmware.h"
>
> -#define DCMD_RESP_TIMEOUT      msecs_to_jiffies(2000)
> -#define CTL_DONE_TIMEOUT       msecs_to_jiffies(2000)
> +#define DCMD_RESP_TIMEOUT      msecs_to_jiffies(2500)
> +#define CTL_DONE_TIMEOUT       msecs_to_jiffies(2500)
>
>  #ifdef DEBUG
>
> --
> 2.7.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
