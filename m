From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH] vxlan: hide unused local variable
Date: Mon, 7 Nov 2016 16:25:54 -0800
Message-ID: <CAOrHB_AU1vEhff=3CsZTxRbd5z2ixEAV3VtAHDohs3LFXP2snA@mail.gmail.com>
References: <20161107211017.857340-1-arnd@arndb.de> <CAOrHB_BRnCmka_cQ1ALnOC1Yta7c8_KWrQ7tzr2tX2fbvOjs7g@mail.gmail.com>
 <2394498.yAioIp78MI@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:51885 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750927AbcKHAZ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 19:25:59 -0500
Received: from mfilter16-d.gandi.net (mfilter16-d.gandi.net [217.70.178.144])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 2333DA80C2
        for <netdev@vger.kernel.org>; Tue,  8 Nov 2016 01:25:58 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter16-d.gandi.net (mfilter16-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id bEi-H4o9S7RD for <netdev@vger.kernel.org>;
        Tue,  8 Nov 2016 01:25:56 +0100 (CET)
Received: from mail-it0-f49.google.com (mail-it0-f49.google.com [209.85.214.49])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 3F35BA80CB
        for <netdev@vger.kernel.org>; Tue,  8 Nov 2016 01:25:56 +0100 (CET)
Received: by mail-it0-f49.google.com with SMTP id q124so166202070itd.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 16:25:56 -0800 (PST)
In-Reply-To: <2394498.yAioIp78MI@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 7, 2016 at 2:21 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Monday, November 7, 2016 2:16:30 PM CET Pravin Shelar wrote:
>> On Monday, November 7, 2016, Arnd Bergmann <arnd@arndb.de> wrote:
>>
>> > A bugfix introduced a harmless warning in v4.9-rc4:
>> >
>> > drivers/net/vxlan.c: In function 'vxlan_group_used':
>> > drivers/net/vxlan.c:947:21: error: unused variable 'sock6'
>> > [-Werror=unused-variable]
>> >
>> > This hides the variable inside of the same #ifdef that is
>> > around its user. The extraneous initialization is removed
>> > at the same time, it was accidentally introduced in the
>> > same commit.
>> >
>> > Fixes: c6fcc4fc5f8b ("vxlan: avoid using stale vxlan socket.")
>> > Signed-off-by: Arnd Bergmann <arnd@arndb.de <javascript:;>>
>> > ---
>>
>>
>> I have already submitted patch to fix this issue.
>>
>> https://patchwork.ozlabs.org/patch/691588/
>
> You have tagged those seven patches for net-next which seems
> appropriate, but as I wrote above the commit that introduced
> it was merged between -rc3 and -rc4, so I think we still need a
> fix for v4.9, right?
>

This is not actual bug, So I am not sure if we need the fix for net branch.
