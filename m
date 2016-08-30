From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v4] brcmfmac: add missing header dependencies
Date: Tue, 30 Aug 2016 19:08:33 +0300
Message-ID: <87twe244u6.fsf@kamboji.qca.qualcomm.com>
References: <1472474375-29910-1-git-send-email-baoyou.xie@linaro.org>
        <CACna6rytnp7WsrdscwPOTvi=FajAtoF2V2ZKx34RUdjEOiZO1w@mail.gmail.com>
        <CA+DQWkxpoScXLNhScNpwmLnaMhgVHoGLrH72dAm7OiOX2nW2vA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        "linux-wireless\@vger.kernel.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list\:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, xie.baoyou-Th6q7B73Y6EnDS1+zs4M5A@public.gmane.org
To: Baoyou Xie <baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+DQWkxpoScXLNhScNpwmLnaMhgVHoGLrH72dAm7OiOX2nW2vA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
        (Baoyou Xie's message of "Tue, 30 Aug 2016 19:15:35 +0800")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Baoyou Xie <baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> writes:

> On 29 August 2016 at 23:31, Rafał Miłecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>     On 29 August 2016 at 14:39, Baoyou Xie <baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
>     > We get 1 warning when build kernel with W=1:
>     > drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c:23:6:
>     warning: no previous prototype for '__brcmf_err' [-Wmissing-prototypes]
>
>     building? I'm not native English, but I think so.
>    
>
>     > In fact, this function is declared in brcmfmac/debug.h, so this patch
>     > add missing header dependencies.
>
>     adds
>    
>
>     > Signed-off-by: Baoyou Xie <baoyou.xie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>     > Acked-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
>
>     Please don't resend patches just to add tags like that. This only
>     increases a noise and patchwork handles this just fine, see:
>     https://patchwork.kernel.org/patch/9303285/
>     https://patchwork.kernel.org/patch/9303285/mbox/
>
>
> Do I need to resend a patch that fixes two typos(build/add)? or you modify them
> on your way?

I can fix those when I commit the patch.

-- 
Kalle Valo
