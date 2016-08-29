From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v4] brcmfmac: add missing header dependencies
Date: Mon, 29 Aug 2016 17:31:50 +0200
Message-ID: <CACna6rytnp7WsrdscwPOTvi=FajAtoF2V2ZKx34RUdjEOiZO1w@mail.gmail.com>
References: <1472474375-29910-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl@broadcom.com>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Arnd Bergmann <arnd@arndb.de>, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472474375-29910-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29 August 2016 at 14:39, Baoyou Xie <baoyou.xie@linaro.org> wrote:
> We get 1 warning when build kernel with W=1:
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c:23:6: warning: no previous prototype for '__brcmf_err' [-Wmissing-prototypes]

building? I'm not native English, but I think so.


> In fact, this function is declared in brcmfmac/debug.h, so this patch
> add missing header dependencies.

adds


> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Please don't resend patches just to add tags like that. This only
increases a noise and patchwork handles this just fine, see:
https://patchwork.kernel.org/patch/9303285/
https://patchwork.kernel.org/patch/9303285/mbox/
