From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v4,2/9] brcmsmac: split up wlc_phy_workarounds_nphy
Date: Mon,  2 Oct 2017 13:55:56 +0000 (UTC)
Message-ID: <20171002135556.82A7D60B7C@smtp.codeaurora.org>
References: <20170922212930.620249-3-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Chi-Hsien Lin <chi-hsien.lin@cypress.com>,
        Wright Feng <wright.feng@cypress.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Jiri Pirko <jiri@resnulli.us>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-media@vger.ke
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922212930.620249-3-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:

> The stack consumption in this driver is still relatively high, with one
> remaining warning if the warning level is lowered to 1536 bytes:
> 
> drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c:17135:1: error: the frame size of 1880 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
> 
> The affected function is actually a collection of three separate implementations,
> and each of them is fairly large by itself. Splitting them up is done easily
> and improves readability at the same time.
> 
> I'm leaving the original indentation to make the review easier.
> 
> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

I'll queue this for v4.15. Depends on:

c503dd38f850 brcmsmac: make some local variables 'static const' to reduce stack size

-- 
https://patchwork.kernel.org/patch/9967141/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
