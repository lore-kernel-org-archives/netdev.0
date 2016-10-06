From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ethernet: qualcomm: QCOM_EMAC should depend on HAS_DMA
Date: Thu, 6 Oct 2016 16:10:17 +0200
Message-ID: <CAMuHMdUGB6__ExtGTCpxOBXBG_=L9GNy1-g10VuCtqZvWRV5Tg@mail.gmail.com>
References: <1475762253-16759-1-git-send-email-geert@linux-m68k.org> <57F65A73.7020701@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:35316 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752013AbcJFOKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 10:10:19 -0400
In-Reply-To: <57F65A73.7020701@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 6, 2016 at 4:06 PM, Timur Tabi <timur@codeaurora.org> wrote:
> Geert Uytterhoeven wrote:
>>
>>   config QCOM_EMAC
>>         tristate "Qualcomm Technologies, Inc. EMAC Gigabit Ethernet
>> support"
>> +       depends on HAS_DMA
>
>
> I think it needs to depend on HAS_IOMEM as well, to fix this error in
> arch/um:
>
>    drivers/net/ethernet/qualcomm/emac/emac.c: In function 'emac_remove':
>>> drivers/net/ethernet/qualcomm/emac/emac.c:727:3: error: implicit
>>> declaration of function 'iounmap' [-Werror=implicit-function-declaration]
>       iounmap(adpt->phy.digital);

Probably, I don't do UML allmodconfig builds.

Gr{oetje,eeting}s,

                        Geert
