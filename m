From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] cfg80211: Fix a memory leak in error handling path in 'brcmf_cfg80211_attach'
Date: Tue, 20 Jun 2017 09:33:32 +0300
Message-ID: <871sqfcgn7.fsf@codeaurora.org>
References: <20170620062205.16078-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: arend.vanspriel@broadcom.com, franky.lin@broadcom.com,
        hante.meuleman@broadcom.com, rafal@milecki.pl,
        pieter-paul.giesberts@broadcom.com, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170620062205.16078-1-christophe.jaillet@wanadoo.fr>
        (Christophe JAILLET's message of "Tue, 20 Jun 2017 08:22:05 +0200")
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christophe JAILLET <christophe.jaillet@wanadoo.fr> writes:

> If 'wiphy_new()' fails, we leak 'ops'. Add a new label in the error
> handling path to free it in such a case.
>
> Fixes: 5c22fb85102a7 ("brcmfmac: add wowl gtk rekeying offload support")
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

The prefix should be "brcmfmac:", like in the commit you are fixing.
"cfg80211:" is very misleading.

-- 
Kalle Valo
