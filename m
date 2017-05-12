From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] brcmfmac: btcoex: replace init_timer with setup_timer
Date: Fri, 12 May 2017 11:19:06 +0300
Message-ID: <87tw4qqyh1.fsf@kamboji.qca.qualcomm.com>
References: <20170512073555.12333-1-cheerx1994@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Xie Qirong <cheerx1994@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170512073555.12333-1-cheerx1994@gmail.com> (Xie Qirong's
        message of "Fri, 12 May 2017 15:35:55 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Xie Qirong <cheerx1994@gmail.com> writes:

> The combination of init_timer and setting up the data and function field
> manually is equivalent to calling setup_timer(). This is an api
> consolidation only and improves readability.
>
> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
> Signed-off-by: Xie Qirong <cheerx1994@gmail.com>
> ---
>
>  setup_timer.cocci suggested the following improvement:
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c:383:1-11: Use
>  setup_timer function for function on line 384.
>
>  Patch was compile checked with: x86_64_defconfig + CONFIG_BRCMFMAC=y +
>  CONFIG_BRCMFMAC_USB=y + CONFIG_BRCMFMAC_PCIE=y + CONFIG_BRCM_TRACING=y +
>  CONFIG_BRCMDBG=y
>
>  Kernel version: 4.11.0 (localversion-next is next-20170512)

How is this different from the first version?

https://patchwork.kernel.org/patch/9709467/

Always add patch version "[PATCH v2]" and a changelog. I added a section
"Frequent problems" to the wiki to mention about these common problems:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches#patch_version_missing

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches#changelog_missing

-- 
Kalle Valo
