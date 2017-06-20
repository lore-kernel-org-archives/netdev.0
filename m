From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] cfg80211: Fix a memory leak in error handling path in
 'brcmf_cfg80211_attach'
Date: Tue, 20 Jun 2017 21:53:15 +0200
Message-ID: <2343c662-f70d-1e76-d863-5f6bb66c269b@broadcom.com>
References: <20170620062205.16078-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        franky.lin@broadcom.com, hante.meuleman@broadcom.com,
        kvalo@codeaurora.org, rafal@milecki.pl,
        pieter-paul.giesberts@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620062205.16078-1-christophe.jaillet@wanadoo.fr>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 20-06-17 08:22, Christophe JAILLET wrote:
> If 'wiphy_new()' fails, we leak 'ops'. Add a new label in the error
> handling path to free it in such a case.

Thanks. Please add the following tags:

Cc: stable@vger.kernel.org
> Fixes: 5c22fb85102a7 ("brcmfmac: add wowl gtk rekeying offload support")
Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
