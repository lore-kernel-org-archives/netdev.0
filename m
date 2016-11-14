From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Mon, 14 Nov 2016 08:47:22 +0100
Message-ID: <68696e92-d056-5f29-9e71-72066f0c7673@st.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
 <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
 <CAFBinCC0HiEXx5mELztH6jYfUq2f1u0Tb+pSzAvwQSu9vYydGQ@mail.gmail.com>
 <20161031112524.4c4ee8f8@gmail.com> <1478192276.6632.34.camel@baylibre.com>
 <3c21b0a4-43c9-0257-f8f2-c8e02cf94fbf@st.com>
 <CAFBinCDq0neyidQBO13F4Yz-GZPorGyRQ2t5Vb-PL0Ls582+4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Jerome Brunet <jbrunet@baylibre.com>,
        =?UTF-8?Q?Andr=c3=a9_Roth?= <neolynx@gmail.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Johnson Leung <r58129@freescale.com>,
        <linux-amlogic@lists.infradead.org>, <netdev@vger.kernel.org>,
        <afaerber@suse.de>
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:49245 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933850AbcKNHsD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 02:48:03 -0500
In-Reply-To: <CAFBinCDq0neyidQBO13F4Yz-GZPorGyRQ2t5Vb-PL0Ls582+4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Martin

On 11/7/2016 6:37 PM, Martin Blumenstingl wrote:
> Hi Peppe,
>
> On Mon, Nov 7, 2016 at 11:59 AM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com> wrote:
>> In the meantime, I will read again the thread just to see if
>> there is something I am missing.
> if you are re-reading this thread: please note that there are two
> devices in discussion here!

many thx for the sum :-)

> Both are using the Amlogic S905 (GXBB) SoC and both are experiencing
> the same issue (Gbit TX issues, RX with Gbit speeds and RX/TX with
> 100Mbit speed are NOT affected):
> - Odroid-C2 (used by Jerome and André Roth)
> - Tronsmart Vega S95 Meta (my device)
>
> The (Gbit TX) problem seems to be gone on the Odroid-C2 with Jerome's
> patch which disables EEE in drivers/net/phy/realtek.c (at least in his
> tests, I don't have that device so I can't verify).
> The same problem still appears on my Tronsmart Vega S95 Meta even with
> the patched PHY driver.

just an doubt, maybe useful, in the past, on GiGa setup I saw similar
problems and it was due to retiming so maybe 2ns could be necessary
(or better granularity via PAD logic if available).

Regards
Peppe

> Unfortunately I don't have a second device to rule out that my
> Tronsmart Vega S95 Meta could be broken (not unlikely, I get DDR
> errors from time to time in u-boot). Maybe Andreas Faerber can test
> ethernet with and without Jerome's patch on one of his Tronsmart
> devices.
>
>
> Regards,
> Martin
>
