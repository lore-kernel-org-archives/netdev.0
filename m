From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not working with wireless drivers
Date: Sat, 12 Aug 2017 10:35:43 +0300
Message-ID: <87tw1dck6o.fsf@kamboji.qca.qualcomm.com>
References: <87shh0gewn.fsf@kamboji.qca.qualcomm.com>
        <8845e49b-3165-e6df-5935-c86278d220d9@broadcom.com>
        <CADps9UA7S2betC-+5sOXjYWmDC8gnk6JJ9aEueEOoYAC3DU8hg@mail.gmail.com>
        <87tw1edz5j.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, James Feeney <james@nurealm.net>
To: Andreas Born <futur.andy@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:36452 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdHLHfu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 03:35:50 -0400
In-Reply-To: <87tw1edz5j.fsf@kamboji.qca.qualcomm.com> (Kalle Valo's message
        of "Fri, 11 Aug 2017 16:14:48 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kalle Valo <kvalo@codeaurora.org> writes:

> Andreas Born <futur.andy@googlemail.com> writes:
>
>> Earlier today I submitted the patch (bonding: require speed/duplex
>> only for 802.3ad, alb and tlb) [2] that only partially reverts what is
>> a regression following my aforementioned logic. This seems to me like
>> the best solution in the short term since it should satisfy both
>> usergroups represented by Mahesh and James and restores consistence
>> with the bonding documentation. James already commented approvingly on
>> that patch in the bug report. [3]
>>
>> Regards
>> Andreas
>>
>> [1]
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/bonding.txt
>
> Great, thanks.
>
> I'll take it the patch is meant for net tree (and not net-next) so that
> it will be fixed for v4.13? Also it should backported to v4.12 stable
> tree. I don't see any mention of that in the patch submission and that's
> why I'm asking.

I see that Dave applied this to the net tree and queued also for stable,
excellent. Thanks everyone!

https://patchwork.ozlabs.org/patch/800080/

-- 
Kalle Valo
