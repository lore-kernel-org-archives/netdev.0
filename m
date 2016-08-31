From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3 0/5] meson: Meson8b and GXBB DWMAC glue driver
Date: Tue, 30 Aug 2016 21:57:32 -0700 (PDT)
Message-ID: <20160830.215732.429612225008644820.davem@davemloft.net>
References: <20160828161637.9941-1-martin.blumenstingl@googlemail.com>
        <20160828.234008.445367966910278179.davem@davemloft.net>
        <CAFBinCCmg-+8mjd0Xc5c7bEWL9_S_4kizs_UMiiW9ATBH_G8iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org, mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
To: martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAFBinCCmg-+8mjd0Xc5c7bEWL9_S_4kizs_UMiiW9ATBH_G8iw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date: Tue, 30 Aug 2016 20:49:28 +0200

> On Mon, Aug 29, 2016 at 5:40 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
>> Date: Sun, 28 Aug 2016 18:16:32 +0200
>>
>>> This adds a DWMAC glue driver for the PRG_ETHERNET registers found in
>>> Meson8b and GXBB SoCs. Based on the "old" meson6b-dwmac glue driver
>>> the register layout is completely different.
>>> Thus I introduced a separate driver.
>>>
>>> Changes since v2:
>>> - fixed unloading the glue driver when built as module. This pulls in a
>>>   patch from Joachim Eastwood (thanks) to get our private data structure
>>>   (bsp_priv).
>>
>> This doesn't apply cleanly at all to the net-next tree, so I have
>> no idea where you expect these changes to be applied.
> OK, maybe Kevin can me help out here as I think the patches should go
> to various trees.
> 
> I think patches 1, 3 and 4 should go through the net-next tree (as
> these touch drivers/net/ethernet/stmicro/stmmac/ and the corresponding
> documentation).
> Patch 2 should probably go through clk-meson-gxbb / clk-next (just
> like the other clk changes we had).
> The last patch (patch 5) should probably go through the ARM SoC tree
> (just like the other dts changes we had).
> 
> @David, Kevin: would this be fine for you?

I would prefer if all of the patches went through one tree, that way
all the dependencies are satisfied in one place.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
