From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 0/4]  Add Ethernet support on STM32F429
Date: Wed, 3 Feb 2016 16:21:39 +0100
Message-ID: <56B21B03.507@st.com>
References: <1454511275-9791-1-git-send-email-alexandre.torgue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>
To: Alexandre TORGUE <alexandre.torgue@gmail.com>,
	Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:14095 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751901AbcBCPWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 10:22:12 -0500
In-Reply-To: <1454511275-9791-1-git-send-email-alexandre.torgue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Alex

On 2/3/2016 3:54 PM, Alexandre TORGUE wrote:
> STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
> This series:
> 	-enhance current stmmac driver to control it (code already available) and
> 	 adds basic glue for STM32F429 chip.
> 	-Enable basic Net config in kernel.
>
> Note that DT patches are not present because STM32 pinctrl code is not
> yet avalaible.

patches look ok for me

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

>
> Regards
>
> Alexandre
>
> Alexandre TORGUE (4):
>    net: ethernet: dwmac: add Ethernet glue logic for stm32 chip
>    Documentation: Bindings: Add STM32 DWMAC glue
>    net: ethernet: stmmac: add support of Synopsys 3.50a MAC IP
>    ARM: STM32: Enable Ethernet in stm32_defconfig
>
>   .../devicetree/bindings/net/stm32-dwmac.txt        |  41 +++++
>   arch/arm/configs/stm32_defconfig                   |   9 ++
>   drivers/net/ethernet/stmicro/stmmac/Kconfig        |  12 ++
>   drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>   drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c  | 177 +++++++++++++++++++++
>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   1 +
>   6 files changed, 241 insertions(+)
>   create mode 100644 Documentation/devicetree/bindings/net/stm32-dwmac.txt
>   create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
>
