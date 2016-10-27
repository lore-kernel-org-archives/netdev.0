From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [19/28] brcmfmac: avoid maybe-uninitialized warning in
 brcmf_cfg80211_start_ap
Date: Thu, 27 Oct 2016 15:05:23 +0000 (UTC)
Message-ID: <20161027150523.B600361656@smtp.codeaurora.org>
References: <20161017221355.1861551-7-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Pieter-Paul Giesberts <pieter-paul.giesberts-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        "Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161017221355.1861551-7-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> A bugfix added a sanity check around the assignment and use of the
> 'is_11d' variable, which looks correct to me, but as the function is
> rather complex already, this confuses the compiler to the point where
> it can no longer figure out if the variable is always initialized
> correctly:
> 
> brcm80211/brcmfmac/cfg80211.c: In function ‘brcmf_cfg80211_start_ap’:
> brcm80211/brcmfmac/cfg80211.c:4586:10: error: ‘is_11d’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This adds an initialization for the newly introduced case in which
> the variable should not really be used, in order to make the warning
> go away.
> 
> Fixes: b3589dfe0212 ("brcmfmac: ignore 11d configuration errors")
> Cc: Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Cc: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Patch applied to wireless-drivers.git, thanks.

d3532ea6ce4e brcmfmac: avoid maybe-uninitialized warning in brcmf_cfg80211_start_ap

-- 
https://patchwork.kernel.org/patch/9380763/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
