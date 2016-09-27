From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [V2,
 4.9] brcmfmac: use correct skb freeing helper when deleting flowring
Date: Tue, 27 Sep 2016 15:48:19 +0000 (UTC)
Message-ID: <20160927154819.309F561405@smtp.codeaurora.org>
References: <20160927121104.5771-1-zajec5@gmail.com>
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
Received: from smtp.codeaurora.org ([198.145.29.96]:43212 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932674AbcI0PsT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 11:48:19 -0400
In-Reply-To: <20160927121104.5771-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> Flowrings contain skbs waiting for transmission that were passed to us
> by netif. It means we checked every one of them looking for 802.1x
> Ethernet type. When deleting flowring we have to use freeing function
> that will check for 802.1x type as well.
> 
> Freeing skbs without a proper check was leading to counter not being
> properly decreased. This was triggering a WARNING every time
> brcmf_netdev_wait_pend8021x was called.
> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
> Acked-by: Arend van Spriel <arend@broadcom.com>
> Cc: stable@vger.kernel.org # 4.5+

Patch applied to wireless-drivers-next.git, thanks.

7f00ee2bbc63 brcmfmac: use correct skb freeing helper when deleting flowring

-- 
https://patchwork.kernel.org/patch/9351797/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
