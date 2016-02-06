From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: sdio: Increase the default timeouts a bit
Date: Sat,  6 Feb 2016 11:59:10 +0000 (UTC)
Message-ID: <20160206115910.E1D026029F@smtp.codeaurora.org>
References: <1453718849-3508-1-git-send-email-sjoerd.simons@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Paul Stewart <pstew@chromium.org>,
	Doug Anderson <dianders@chromium.org>,
	linux-rockchip@lists.infradead.org,
	Arend van Spriel <arend@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Hante Meuleman <meuleman@broadcom.com>,
	Brett Rudley <brudley@broadcom.com>, netdev@vger.kernel.org,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Sjoerd Simons <sjoerd.simons@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53578 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbcBFL7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 06:59:11 -0500
In-Reply-To: <1453718849-3508-1-git-send-email-sjoerd.simons@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


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
> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>
> Acked-by: Arend van Spriel <arend@broadcom.com>
> Reviewed-by: Douglas Anderson <dianders@chromium.org>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
