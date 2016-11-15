From: Jerome Brunet <jbrunet@baylibre.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Tue, 15 Nov 2016 12:27:56 +0100
Message-ID: <1479209276.2619.10.camel@baylibre.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
         <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
         <CAFBinCC0HiEXx5mELztH6jYfUq2f1u0Tb+pSzAvwQSu9vYydGQ@mail.gmail.com>
         <20161031112524.4c4ee8f8@gmail.com> <1478192276.6632.34.camel@baylibre.com>
         <3c21b0a4-43c9-0257-f8f2-c8e02cf94fbf@st.com>
         <CAFBinCDq0neyidQBO13F4Yz-GZPorGyRQ2t5Vb-PL0Ls582+4Q@mail.gmail.com>
         <24b4d9b3-0a9d-5f6c-7dc2-5fcbb1012481@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org,
        =?ISO-8859-1?Q?Andr=E9?= Roth <neolynx@gmail.com>,
        Johnson Leung <r58129@freescale.com>,
        linux-amlogic@lists.infradead.org
To: Andreas =?ISO-8859-1?Q?F=E4rber?= <afaerber@suse.de>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36998 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbcKOL17 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 06:27:59 -0500
Received: by mail-wm0-f44.google.com with SMTP id t79so161895879wmt.0
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 03:27:58 -0800 (PST)
In-Reply-To: <24b4d9b3-0a9d-5f6c-7dc2-5fcbb1012481@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-14 at 16:00 +0100, Andreas Färber wrote:
> Hi,
> 
> Am 07.11.2016 um 18:37 schrieb Martin Blumenstingl:
> > 
> > The same problem still appears on my Tronsmart Vega S95 Meta even
> > with
> > the patched PHY driver.
> > 
> > Unfortunately I don't have a second device to rule out that my
> > Tronsmart Vega S95 Meta could be broken (not unlikely, I get DDR
> > errors from time to time in u-boot). Maybe Andreas Faerber can test
> > ethernet with and without Jerome's patch on one of his Tronsmart
> > devices.
> 
> So far I only ran into the stall issue on my Odroid-C2, not on my
> Vega
> S95 Telos, both on v4.10/integ branch with a rebased MMC patch of
> yours
> on top.

The status of vega/mxq boards seems a bit confused.
This is the status I have so far:
These designs are not affected by the EEE issue. The patch mentioned
has no effect on these boards.
Some boards run fine at GBit speed (like yours) , some have terrible Tx
throughput (like mine and Martin's one). However, unlike on the
odroidc2, the link is not broken after the test, it is not necessary to
ifdown/ifup the interface to do another test.

I'm wondering if the vega/mxq designs all use the rtl8211f phy ?

> 
> I'm assuming you mean realtek8211f-disable-eee-1000.patch from Nov 3.
> 

Indeed. I won't submit anything for the vega since it has no effect.

> Regards,
> Andreas
> 
