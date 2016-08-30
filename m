From: Caesar Wang <wxt@rock-chips.com>
Subject: [PATCH 0/4] Support the rk3399 gmac pd function
Date: Wed, 31 Aug 2016 04:30:03 +0800
Message-ID: <1472589008-7713-1-git-send-email-wxt@rock-chips.com>
Cc: linux-rockchip@lists.infradead.org,
        Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>,
        dbasehore@chromium.org, Caesar Wang <wxt@rock-chips.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Frank Wang <frank.wang@rock-chips.com>,
        Rob Herring <robh+dt@kernel.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Elaine Zhang <zhangqing@rock-chips.com>,
        David Wu <david.wu@rock-chips.com>,
        Will Deacon <will.deacon@arm.com>, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Jianqun Xu <jay.xu@rock-chips.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        linux-kernel@vger.kernel.org,
        Shunqian Zheng <zhengsq@rock-chips.com>,
        Mark
To: Heiko Stuebner <heiko@sntech.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34757 "EHLO
        mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756082AbcH3UaY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 16:30:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add to handle the gmac pd issue, and support
the rk3399 gmac for devicetree.



Caesar Wang (2):
  arm64: dts: rockchip: support gmac for rk3399
  arm64: dts: rockchip: enable the gmac for rk3399 evb board

David Wu (1):
  net: stmmac: dwmac-rk: add pd_gmac support for rk3399

Roger Chen (1):
  net: stmmac: dwmac-rk: fixes the gmac resume after PD on/off

 arch/arm64/boot/dts/rockchip/rk3399-evb.dts    | 31 +++++++++
 arch/arm64/boot/dts/rockchip/rk3399.dtsi       | 90 ++++++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 27 +++++---
 3 files changed, 139 insertions(+), 9 deletions(-)

-- 
1.9.1
