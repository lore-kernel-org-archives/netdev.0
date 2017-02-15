From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: Use net_device_stats from struct net_device
Date: Wed, 15 Feb 2017 09:15:47 +0000 (UTC)
Message-ID: <20170215091547.8B70660C53@smtp.codeaurora.org>
References: <20170213101409.8205-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: arend.vanspriel@broadcom.com, franky.lin@broadcom.com,
        hante.meuleman@broadcom.com, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46476 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdBOJPs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 04:15:48 -0500
In-Reply-To: <20170213101409.8205-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Klauser <tklauser@distanz.ch> wrote:
> Instead of using a private copy of struct net_device_stats in struct
> brcm_if, use stats from struct net_device.  Also remove the now
> unnecessary .ndo_get_stats function.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>

Patch applied to wireless-drivers-next.git, thanks.

91b632803ee4 brcmfmac: Use net_device_stats from struct net_device

-- 
https://patchwork.kernel.org/patch/9569271/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
