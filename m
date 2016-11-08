From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: hide unused local variable
Date: Mon, 07 Nov 2016 20:18:19 -0500 (EST)
Message-ID: <20161107.201819.454417099982933747.davem@davemloft.net>
References: <CAOrHB_BRnCmka_cQ1ALnOC1Yta7c8_KWrQ7tzr2tX2fbvOjs7g@mail.gmail.com>
        <2394498.yAioIp78MI@wuerfel>
        <CAOrHB_AU1vEhff=3CsZTxRbd5z2ixEAV3VtAHDohs3LFXP2snA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, jbenc@redhat.com, hannes@stressinduktion.org,
        aduyck@mirantis.com, netdev@vger.kernel.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47646 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750926AbcKHBSW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 20:18:22 -0500
In-Reply-To: <CAOrHB_AU1vEhff=3CsZTxRbd5z2ixEAV3VtAHDohs3LFXP2snA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@ovn.org>
Date: Mon, 7 Nov 2016 16:25:54 -0800

> On Mon, Nov 7, 2016 at 2:21 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Monday, November 7, 2016 2:16:30 PM CET Pravin Shelar wrote:
>>> On Monday, November 7, 2016, Arnd Bergmann <arnd@arndb.de> wrote:
>>>
>>> > A bugfix introduced a harmless warning in v4.9-rc4:
>>> >
>>> > drivers/net/vxlan.c: In function 'vxlan_group_used':
>>> > drivers/net/vxlan.c:947:21: error: unused variable 'sock6'
>>> > [-Werror=unused-variable]
>>> >
>>> > This hides the variable inside of the same #ifdef that is
>>> > around its user. The extraneous initialization is removed
>>> > at the same time, it was accidentally introduced in the
>>> > same commit.
>>> >
>>> > Fixes: c6fcc4fc5f8b ("vxlan: avoid using stale vxlan socket.")
>>> > Signed-off-by: Arnd Bergmann <arnd@arndb.de <javascript:;>>
>>> > ---
>>>
>>>
>>> I have already submitted patch to fix this issue.
>>>
>>> https://patchwork.ozlabs.org/patch/691588/
>>
>> You have tagged those seven patches for net-next which seems
>> appropriate, but as I wrote above the commit that introduced
>> it was merged between -rc3 and -rc4, so I think we still need a
>> fix for v4.9, right?
>>
> 
> This is not actual bug, So I am not sure if we need the fix for net branch.

Really ugly warnings like this really need to be fixed in 'net'.
