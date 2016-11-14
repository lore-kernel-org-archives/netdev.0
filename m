From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Mon, 14 Nov 2016 16:00:52 +0100
Message-ID: <24b4d9b3-0a9d-5f6c-7dc2-5fcbb1012481@suse.de>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
 <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
 <CAFBinCC0HiEXx5mELztH6jYfUq2f1u0Tb+pSzAvwQSu9vYydGQ@mail.gmail.com>
 <20161031112524.4c4ee8f8@gmail.com> <1478192276.6632.34.camel@baylibre.com>
 <3c21b0a4-43c9-0257-f8f2-c8e02cf94fbf@st.com>
 <CAFBinCDq0neyidQBO13F4Yz-GZPorGyRQ2t5Vb-PL0Ls582+4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org,
        =?UTF-8?Q?Andr=c3=a9_Roth?= <neolynx@gmail.com>,
        Johnson Leung <r58129@freescale.com>,
        linux-amlogic@lists.infradead.org,
        Jerome Brunet <jbrunet@baylibre.com>
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59942 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932786AbcKNPAy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 10:00:54 -0500
In-Reply-To: <CAFBinCDq0neyidQBO13F4Yz-GZPorGyRQ2t5Vb-PL0Ls582+4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Am 07.11.2016 um 18:37 schrieb Martin Blumenstingl:
> The same problem still appears on my Tronsmart Vega S95 Meta even with
> the patched PHY driver.
> 
> Unfortunately I don't have a second device to rule out that my
> Tronsmart Vega S95 Meta could be broken (not unlikely, I get DDR
> errors from time to time in u-boot). Maybe Andreas Faerber can test
> ethernet with and without Jerome's patch on one of his Tronsmart
> devices.

So far I only ran into the stall issue on my Odroid-C2, not on my Vega
S95 Telos, both on v4.10/integ branch with a rebased MMC patch of yours
on top.

I'm assuming you mean realtek8211f-disable-eee-1000.patch from Nov 3.

Regards,
Andreas

-- 
SUSE Linux GmbH, Maxfeldstr. 5, 90409 Nürnberg, Germany
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
