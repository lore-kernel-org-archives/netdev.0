From: Maxime Coquelin <mcoquelin.stm32@gmail.com>
Subject: Re: [PATCH v2 0/4] Add Ethernet support on STM32F429
Date: Tue, 1 Mar 2016 18:39:21 +0100
Message-ID: <56D5D3C9.9070104@gmail.com>
References: <1456240244-10275-1-git-send-email-alexandre.torgue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Alexandre TORGUE <alexandre.torgue@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36334 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbcCARkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 12:40:12 -0500
In-Reply-To: <1456240244-10275-1-git-send-email-alexandre.torgue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

On 02/23/2016 04:10 PM, Alexandre TORGUE wrote:
> STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
> This series:
>   -enhance current stmmac driver to control it (code already
> available) and adds basic glue for STM32F429 chip.
>   -Enable basic Net config in kernel.
>
> Note that DT patches are not present because STM32 pinctrl code is not
> yet avalaible.
>
> Changes since v1:
>   -Fix Kbuild issue in Kconfig.
>   -Remove init/exit callbacks. Suspend/Resume and remove driver is no more
> driven in stmmac_pltfr but directly in dwmac-stm32 glue driver.
>   -Take into account Joachim review.
>
> Regards.
>
> Alexandre.
>
> Alexandre TORGUE (4):
>    net: ethernet: dwmac: add Ethernet glue logic for stm32 chip
>    Documentation: Bindings: Add STM32 DWMAC glue
>    net: ethernet: stmmac: add support of Synopsys 3.50a MAC IP
>    ARM: STM32: Enable Ethernet in stm32_defconfig
>
>   .../devicetree/bindings/net/stm32-dwmac.txt        |  41 ++++
>   arch/arm/configs/stm32_defconfig                   |   9 +
>   drivers/net/ethernet/stmicro/stmmac/Kconfig        |  12 ++
>   drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>   drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c  | 208 +++++++++++++++++++++
>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   1 +
>   6 files changed, 272 insertions(+)
>   create mode 100644 Documentation/devicetree/bindings/net/stm32-dwmac.txt
>   create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
>

You can add my:
Tested-by: Maxime Coquelin <maxime.coquelin@st.com>

Thanks!
Maxime
