From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3 0/5] meson: Meson8b and GXBB DWMAC glue driver
Date: Fri, 02 Sep 2016 10:50:38 +0200
Message-ID: <5097106.VWHdyQfjWO@wuerfel>
References: <CAFBinCCmg-+8mjd0Xc5c7bEWL9_S_4kizs_UMiiW9ATBH_G8iw@mail.gmail.com> <m2poonexpj.fsf@baylibre.com> <20160901.223731.1152520865580611814.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, khilman@baylibre.com,
        mark.rutland@arm.com, devicetree@vger.kernel.org,
        sboyd@codeaurora.org, alexandre.torgue@st.com,
        martin.blumenstingl@googlemail.com, catalin.marinas@arm.com,
        mturquette@baylibre.com, will.deacon@arm.com, manabian@gmail.com,
        robh+dt@kernel.org, peppe.cavallaro@st.com, carlo@caione.org,
        linux-amlogic@lists.infradead.org, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:61403 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752780AbcIBIv7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 04:51:59 -0400
In-Reply-To: <20160901.223731.1152520865580611814.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, September 1, 2016 10:37:31 PM CEST David Miller wrote:
> From: Kevin Hilman <khilman@baylibre.com>
> Date: Thu, 01 Sep 2016 21:23:52 -0700
> > David Miller <davem@davemloft.net> writes:
> >> From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
> >> Date: Tue, 30 Aug 2016 20:49:28 +0200
> >>> On Mon, Aug 29, 2016 at 5:40 AM, David Miller <davem@davemloft.net> wrote:
> >>>> From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
> >>> I think patches 1, 3 and 4 should go through the net-next tree (as
> >>> these touch drivers/net/ethernet/stmicro/stmmac/ and the corresponding
> >>> documentation).
> >>> Patch 2 should probably go through clk-meson-gxbb / clk-next (just
> >>> like the other clk changes we had).
> >>> The last patch (patch 5) should probably go through the ARM SoC tree
> >>> (just like the other dts changes we had).
> >>> 
> >>> @David, Kevin: would this be fine for you?
> >>
> >> I would prefer if all of the patches went through one tree, that way
> >> all the dependencies are satisfied in one place.
> > 
> > David, with your ack on the drivers/net changes, I can take them through
> > my tree for Amlogic SoCs (which then goes via the arm-soc tree.)
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Thanks!

Note that we (in arm-soc) normally put drivers and DT changes into
separate branches and send a pull request for each branch separately
(though usually on the same day).

We expect there to be no runtime dependency between the DT changes
and the driver changes other than requiring both to make use of
the added features.

Kevin/Martin: in case this one does have a runtime dependency,
please we can put both halves into the next/drivers branch in
the correct order to ensure that they are applied together, and
describe the dependency in the cover letter for the pull request.

	Arnd
