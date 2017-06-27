From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] brcmfmac: Fix a memory leak in error handling path in
 'brcmf_cfg80211_attach'
Date: Tue, 27 Jun 2017 14:16:16 +0000 (UTC)
Message-ID: <20170627141616.F24176071A@smtp.codeaurora.org>
References: <20170621054553.16546-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: arend.vanspriel@broadcom.com, franky.lin@broadcom.com,
        hante.meuleman@broadcom.com, rafal@milecki.pl,
        pieter-paul.giesberts@broadcom.com, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        stable@vger.kernel.org
To: Christophe Jaillet <christophe.jaillet@wanadoo.fr>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170621054553.16546-1-christophe.jaillet@wanadoo.fr>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christophe Jaillet <christophe.jaillet@wanadoo.fr> wrote:

> If 'wiphy_new()' fails, we leak 'ops'. Add a new label in the error
> handling path to free it in such a case.
> 
> Cc: stable@vger.kernel.org
> Fixes: 5c22fb85102a7 ("brcmfmac: add wowl gtk rekeying offload support")
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Patch applied to wireless-drivers-next.git, thanks.

57c00f2fac51 brcmfmac: Fix a memory leak in error handling path in 'brcmf_cfg80211_attach'

-- 
https://patchwork.kernel.org/patch/9800763/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
