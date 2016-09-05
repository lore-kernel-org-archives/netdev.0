From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 4/5] net: stmmac: add a glue driver for the Amlogic Meson 8b / GXBB DWMAC
Date: Mon, 05 Sep 2016 12:53:00 +0200
Message-ID: <14789887.lyko4Om94p@wuerfel>
References: <201609050953.67GKeUAU%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        kbuild-all@01.org, linux-amlogic@lists.infradead.org,
        khilman@baylibre.com, carlo@caione.org, mturquette@baylibre.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
        will.deacon@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        sboyd@codeaurora.org, manabian@gmail.com, davem@davemloft.net
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:56070 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752884AbcIEKyJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 06:54:09 -0400
In-Reply-To: <201609050953.67GKeUAU%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, September 5, 2016 9:37:29 AM CEST kbuild test robot wrote:
> All error/warnings (new ones prefixed by >>):
> 
> >> drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c:63:18: error: field 'm250_mux' has incomplete type
>      struct clk_mux  m250_mux;
>                      ^
> >> drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c:67:21: error: field 'm250_div' has incomplete type
>      struct clk_divider m250_div;
>                         ^
> 

I think this needs a compile-time dependency on COMMON_CLK

	Arnd
