From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2 08/11] brcmsmac: make some local variables 'static const' to reduce stack size
Date: Thu, 15 Jun 2017 17:56:27 +0300
Message-ID: <87mv99e1us.fsf@codeaurora.org>
References: <20170614211556.2062728-1-arnd@arndb.de>
        <20170614211556.2062728-9-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
        kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        linux-wireless@vger.kernel.org, brcm80211-dev-list.pdl@broadcom.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614211556.2062728-9-arnd@arndb.de> (Arnd Bergmann's message
        of "Wed, 14 Jun 2017 23:15:43 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> With KASAN and a couple of other patches applied, this driver is one
> of the few remaining ones that actually use more than 2048 bytes of
> kernel stack:
>
> broadcom/brcm80211/brcmsmac/phy/phy_n.c: In function 'wlc_phy_workarounds_nphy_gainctrl':
> broadcom/brcm80211/brcmsmac/phy/phy_n.c:16065:1: warning: the frame size of 3264 bytes is larger than 2048 bytes [-Wframe-larger-than=]
> broadcom/brcm80211/brcmsmac/phy/phy_n.c: In function 'wlc_phy_workarounds_nphy':
> broadcom/brcm80211/brcmsmac/phy/phy_n.c:17138:1: warning: the frame size of 2864 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>
> Here, I'm reducing the stack size by marking as many local variables as
> 'static const' as I can without changing the actual code.
>
> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

I found the cover letter from lkml and apparently the plan is that
Andrew will pick these three brcmsmac patches, so I'll drop them in
wireless patchwork.

-- 
Kalle Valo
