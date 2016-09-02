From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/5] meson: Meson8b and GXBB DWMAC glue driver
Date: Thu, 01 Sep 2016 22:37:31 -0700 (PDT)
Message-ID: <20160901.223731.1152520865580611814.davem@davemloft.net>
References: <CAFBinCCmg-+8mjd0Xc5c7bEWL9_S_4kizs_UMiiW9ATBH_G8iw@mail.gmail.com>
        <20160830.215732.429612225008644820.davem@davemloft.net>
        <m2poonexpj.fsf@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin.blumenstingl@googlemail.com,
        linux-amlogic@lists.infradead.org, carlo@caione.org,
        mturquette@baylibre.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sboyd@codeaurora.org,
        manabian@gmail.com, arnd@arndb.de
To: khilman@baylibre.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44868 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750873AbcIBFhi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 01:37:38 -0400
In-Reply-To: <m2poonexpj.fsf@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Hilman <khilman@baylibre.com>
Date: Thu, 01 Sep 2016 21:23:52 -0700

> David Miller <davem@davemloft.net> writes:
> 
>> From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
>> Date: Tue, 30 Aug 2016 20:49:28 +0200
>>
>>> On Mon, Aug 29, 2016 at 5:40 AM, David Miller <davem@davemloft.net> wrote:
>>>> From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
>>>> Date: Sun, 28 Aug 2016 18:16:32 +0200
>>>>
>>>>> This adds a DWMAC glue driver for the PRG_ETHERNET registers found in
>>>>> Meson8b and GXBB SoCs. Based on the "old" meson6b-dwmac glue driver
>>>>> the register layout is completely different.
>>>>> Thus I introduced a separate driver.
>>>>>
>>>>> Changes since v2:
>>>>> - fixed unloading the glue driver when built as module. This pulls in a
>>>>>   patch from Joachim Eastwood (thanks) to get our private data structure
>>>>>   (bsp_priv).
>>>>
>>>> This doesn't apply cleanly at all to the net-next tree, so I have
>>>> no idea where you expect these changes to be applied.
>>> OK, maybe Kevin can me help out here as I think the patches should go
>>> to various trees.
>>> 
>>> I think patches 1, 3 and 4 should go through the net-next tree (as
>>> these touch drivers/net/ethernet/stmicro/stmmac/ and the corresponding
>>> documentation).
>>> Patch 2 should probably go through clk-meson-gxbb / clk-next (just
>>> like the other clk changes we had).
>>> The last patch (patch 5) should probably go through the ARM SoC tree
>>> (just like the other dts changes we had).
>>> 
>>> @David, Kevin: would this be fine for you?
>>
>> I would prefer if all of the patches went through one tree, that way
>> all the dependencies are satisfied in one place.
> 
> David, with your ack on the drivers/net changes, I can take them through
> my tree for Amlogic SoCs (which then goes via the arm-soc tree.)

Acked-by: David S. Miller <davem@davemloft.net>
