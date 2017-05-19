From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2 00/10] rt2x00: rt2x00: improve calling conventions for register accessors
Date: Fri, 19 May 2017 10:15:51 +0300
Message-ID: <87efvlwc48.fsf@kamboji.qca.qualcomm.com>
References: <20170517144702.1381136-1-arnd@arndb.de>
        <87r2zl8lvi.fsf@codeaurora.org>
        <CAK8P3a3YGxNBQq3RYucMCCvSyXOD8skF_Db-eba0PcBL4_P8Dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        Stanislaw Gruszka <sgruszka@redhat.com>,
        David Miller <davem@davemloft.net>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        Daniel Golle <daniel@makrotopia.org>,
        Mathias Kresin <dev@kresin.me>,
        Johannes Berg <johannes.berg@intel.com>,
        Serge Vasilugin <vasilugin@yandex.ru>,
        Roman Yeryomin <roman@advem.lv>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Jes Sorensen <jes.sorensen@gmail.com>,
        Tom Psyborg <pozega.tomislav@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37910 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdESHQA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 03:16:00 -0400
In-Reply-To: <CAK8P3a3YGxNBQq3RYucMCCvSyXOD8skF_Db-eba0PcBL4_P8Dg@mail.gmail.com>
        (Arnd Bergmann's message of "Fri, 19 May 2017 08:50:33 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> writes:

> On Fri, May 19, 2017 at 7:18 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
>> Arnd Bergmann <arnd@arndb.de> writes:
>>
>>> I've managed to split up my long patch into a series of reasonble
>>> steps now.
>>>
>>> The first two are required to fix a regression from commit 41977e86c984
>>> ("rt2x00: add support for MT7620"), the rest are just cleanups to
>>> have a consistent state across all the register access functions.
>>
>> Can these all go to 4.13 or would you prefer me to push the first two
>> 4.12? Or what?
>
> I think you can reasonably argue either way: the second patch does
> fix a real bug that may or may not lead to an exploitable stack overflow
> when CONFIG_KASAN is enabled, which would be a reason to put it
> into 4.12. On the other hand, I have another 20 patches for similar
> (or worse) stack overflow issues with KASAN that I'm hoping to all
> get into 4.13 and backported into stable kernel later if necessary,
> so we could treat this one like the others.
>
> The only difference between this and the others is that in rt2x00 it
> is a regression against 4.11, while the others have all been present
> for a long time.

Having all of these in 4.12 sounds a bit excessive and splitting the set
(the first two into 4.12 and the rest into 4.13) sounds too much work.
So I would prefer to queue these to 4.13, if it's ok for everyone?

-- 
Kalle Valo
