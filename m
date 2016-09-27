From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: replace WARNING on timeout with a simple error message
Date: Tue, 27 Sep 2016 15:47:25 +0000 (UTC)
Message-ID: <20160927154725.609A161405@smtp.codeaurora.org>
References: <20160927101224.3534-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Franky Lin <frankyl@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: =?utf-8?b?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43094 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932674AbcI0Pr0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 11:47:26 -0400
In-Reply-To: <20160927101224.3534-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> Even with timeout increased to 950 ms we get WARNINGs from time to time.
> It mostly happens on A-MPDU stalls (e.g. when station goes out of
> range). It may take up to 5-10 secods for the firmware to recover and
> for that time it doesn't process packets.
> 
> It's still useful to have a message on time out as it may indicate some
> firmware problem and incorrect key update. Raising a WARNING however
> wasn't really that necessary, it doesn't point to any driver bug anymore
> and backtrace wasn't much useful.
> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>

Patch applied to wireless-drivers-next.git, thanks.

2f0e56fa37cc brcmfmac: replace WARNING on timeout with a simple error message

-- 
https://patchwork.kernel.org/patch/9351657/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
