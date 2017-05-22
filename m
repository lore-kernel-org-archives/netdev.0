From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v4] brcmfmac: btcoex: replace init_timer with setup_timer
Date: Mon, 22 May 2017 15:19:18 +0000 (UTC)
Message-ID: <20170522151918.8DF6E60AC8@smtp.codeaurora.org>
References: <20170512093259.28479-1-cheerx1994@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Xie Qirong <cheerx1994@gmail.com>
To: Xie Qirong <cheerx1994@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38594 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934647AbdEVPTT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 11:19:19 -0400
In-Reply-To: <20170512093259.28479-1-cheerx1994@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Xie Qirong <cheerx1994@gmail.com> wrote:
> setup_timer.cocci suggested the following improvement:
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c:383:1-11: Use
> setup_timer function for function on line 384.
> 
> The combination of init_timer and setting up the data and function field
> manually is equivalent to calling setup_timer(). This is an api
> consolidation only and improves readability.
> 
> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
> Signed-off-by: Xie Qirong <cheerx1994@gmail.com>

Patch applied to wireless-drivers-next.git, thanks.

6572e5f72d01 brcmfmac: btcoex: replace init_timer with setup_timer

-- 
https://patchwork.kernel.org/patch/9723793/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
