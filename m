From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v4] brcmfmac: add missing header dependencies
Date: Mon, 29 Aug 2016 18:39:25 +0200
Message-ID: <CACna6rwBrT5Ei8oY1qfcCTa5J+xh9PyZUDwwghcXNX1U0E5vuw@mail.gmail.com>
References: <1472474375-29910-1-git-send-email-baoyou.xie@linaro.org> <CACna6rytnp7WsrdscwPOTvi=FajAtoF2V2ZKx34RUdjEOiZO1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
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
In-Reply-To: <CACna6rytnp7WsrdscwPOTvi=FajAtoF2V2ZKx34RUdjEOiZO1w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29 August 2016 at 17:42, Baoyou Xie <baoyou.xie@linaro.org> wrote:
> On 29 August 2016 at 23:31, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> wr=
ote:
>>
>> On 29 August 2016 at 14:39, Baoyou Xie <baoyou.xie@linaro.org> wrote:
>> > We get 1 warning when build kernel with W=3D1:
>> > drivers/net/wireless/broadcom/brcm80211/brcmfmac/tracepoint.c:23:6:
>> > warning: no previous prototype for '__brcmf_err' [-Wmissing-prototypes=
]
>>
>> building? I'm not native English, but I think so.
>>
>>
>> > In fact, this function is declared in brcmfmac/debug.h, so this patch
>> > add missing header dependencies.
>>
>> adds
>>
>>
>> > Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
>> > Acked-by: Arnd Bergmann <arnd@arndb.de>
>>
>> Please don't resend patches just to add tags like that. This only
>> increases a noise and patchwork handles this just fine, see:
>> https://patchwork.kernel.org/patch/9303285/
>> https://patchwork.kernel.org/patch/9303285/mbox/
>
>
> it modifies a typo biuld/build.

Please send your replies to all, not privately.

OK, so you should also include a changelog in the comments part of diff, e.=
g.:
V4: Fix typo in "biuld"
