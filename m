From: Kevin Hilman <khilman@baylibre.com>
Subject: Re: [PATCH v3 0/5] meson: Meson8b and GXBB DWMAC glue driver
Date: Thu, 01 Sep 2016 21:23:52 -0700
Message-ID: <m2poonexpj.fsf@baylibre.com>
References: <20160828161637.9941-1-martin.blumenstingl@googlemail.com>
        <20160828.234008.445367966910278179.davem@davemloft.net>
        <CAFBinCCmg-+8mjd0Xc5c7bEWL9_S_4kizs_UMiiW9ATBH_G8iw@mail.gmail.com>
        <20160830.215732.429612225008644820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: martin.blumenstingl@googlemail.com,
        linux-amlogic@lists.infradead.org, carlo@caione.org,
        mturquette@baylibre.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sboyd@codeaurora.org,
        manabian@gmail.com, arnd@arndb.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34184 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750742AbcIBEXz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 00:23:55 -0400
Received: by mail-pa0-f53.google.com with SMTP id fi15so36394361pac.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 21:23:55 -0700 (PDT)
In-Reply-To: <20160830.215732.429612225008644820.davem@davemloft.net> (David
        Miller's message of "Tue, 30 Aug 2016 21:57:32 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
> Date: Tue, 30 Aug 2016 20:49:28 +0200
>
>> On Mon, Aug 29, 2016 at 5:40 AM, David Miller <davem@davemloft.net> wrote:
>>> From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
>>> Date: Sun, 28 Aug 2016 18:16:32 +0200
>>>
>>>> This adds a DWMAC glue driver for the PRG_ETHERNET registers found in
>>>> Meson8b and GXBB SoCs. Based on the "old" meson6b-dwmac glue driver
>>>> the register layout is completely different.
>>>> Thus I introduced a separate driver.
>>>>
>>>> Changes since v2:
>>>> - fixed unloading the glue driver when built as module. This pulls in a
>>>>   patch from Joachim Eastwood (thanks) to get our private data structure
>>>>   (bsp_priv).
>>>
>>> This doesn't apply cleanly at all to the net-next tree, so I have
>>> no idea where you expect these changes to be applied.
>> OK, maybe Kevin can me help out here as I think the patches should go
>> to various trees.
>> 
>> I think patches 1, 3 and 4 should go through the net-next tree (as
>> these touch drivers/net/ethernet/stmicro/stmmac/ and the corresponding
>> documentation).
>> Patch 2 should probably go through clk-meson-gxbb / clk-next (just
>> like the other clk changes we had).
>> The last patch (patch 5) should probably go through the ARM SoC tree
>> (just like the other dts changes we had).
>> 
>> @David, Kevin: would this be fine for you?
>
> I would prefer if all of the patches went through one tree, that way
> all the dependencies are satisfied in one place.

David, with your ack on the drivers/net changes, I can take them through
my tree for Amlogic SoCs (which then goes via the arm-soc tree.)

Note that there may be some minor tweaks yet to the clock handling based
on review comments.

Thanks,

Kevin
