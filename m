From: Doug Anderson <dianders@chromium.org>
Subject: Re: [RESEND PATCH 3/4] arm64: dts: rockchip: support gmac for rk3399
Date: Wed, 31 Aug 2016 14:45:40 -0700
Message-ID: <CAD=FV=UkK2QqbCJrg72nvYYfg8-z5p0ye3mkASnxLKQfSR+wTw@mail.gmail.com>
References: <1472624028-7082-1-git-send-email-wxt@rock-chips.com>
 <1472624028-7082-4-git-send-email-wxt@rock-chips.com> <CAD=FV=XQX__rFqGLY2U5mPT8WR4P4aW5tbCqFmA+3rZunbzUZQ@mail.gmail.com>
 <2498365.kqzATN1cjf@diego>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Caesar Wang <wxt@rock-chips.com>, netdev@vger.kernel.org,
        "open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>,
        Brian Norris <briannorris@chromium.org>,
        Derek Basehore <dbasehore@chromium.org>,
        Roger Chen <roger.chen@rock-chips.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Xing Zheng <zhengxing@rock-chips.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Jianqun Xu <jay.xu@rock-chips.com>,
        Elaine Zhang <zhangqing@rock-chips.com>,
        David Wu <david.wu@rock-chips.com>,
        Shunqian Zheng <zhengsq@rock-chips.com>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@li
To: =?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko@sntech.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:36242 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754010AbcHaVpm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 17:45:42 -0400
Received: by mail-ua0-f180.google.com with SMTP id m60so112712487uam.3
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 14:45:42 -0700 (PDT)
In-Reply-To: <2498365.kqzATN1cjf@diego>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Aug 31, 2016 at 2:29 PM, Heiko St=C3=BCbner <heiko@sntech.de> wrote=
:
>> IMHO it would be nice if this were broken into two patches.
>>
>> 1. First patch would be the power domain patch and that could land any
>> time.  You wouldn't actually be able to use the gmac but at least
>> you'd be able to turn off its power.  This would be a handy patch to
>> be able to backport if you happened to not need Ethernet support but
>> wanted to save power.
>>
>> 2. Second patch would actually add the gmac.
>
> according to my talk with Caesar in the real v1, the gmac even with power=
-
> domains should work just nicely even without the dts patches, as the driv=
er
> core takes care of powering up the pd before probe.
>
> But I may miss some peculiarity of the dwmac?

Nothing that I'm terribly aware of.  I was just being selfish because:

1. I'm on a board where I don't need Ethernet.

2. I'm running a semi old kernel (4.4)

3. I don't want to pick back the various fixes that might be needed to
make gmac work on rk3399 to that old kernel.

4. I want it very obvious that gmac isn't really supported on this old
kernel on rk3399 (and having stmmac not in the device tree would make
it very obvious)

5. I do want the power savings of turning the power domains off for the gma=
c.


If this patch is broken in two then I can pick back just the power
domain patch.  :-P



-Doug
