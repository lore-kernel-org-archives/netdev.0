From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v3 0/4] Add Ethernet support on STM32F429
Date: Mon, 29 Feb 2016 10:36:59 +0100
Message-ID: <56D4113B.2000501@st.com>
References: <1456483912-32090-1-git-send-email-alexandre.torgue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>
To: Alexandre TORGUE <alexandre.torgue@gmail.com>,
	Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:57210 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753477AbcB2Jhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 04:37:31 -0500
In-Reply-To: <1456483912-32090-1-git-send-email-alexandre.torgue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/26/2016 11:51 AM, Alexandre TORGUE wrote:
> STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
> This series:
>   -enhance current stmmac driver to control it (code already
> available) and adds basic glue for STM32F429 chip.
>   -Enable basic Net config in kernel.
>
> Note that DT patches are not present because STM32 pinctrl code is not
> yet avalaible.
>
> Changes since v2:
>   -Fix alphabetic order in Kconfig and Makefile.
>   -Improve code according to Joachim review.
>   -Binding: remove useless entry.
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

thanks Alex, for the series please consider my:

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>


>
> Alexandre TORGUE (4):
>    net: ethernet: dwmac: add Ethernet glue logic for stm32 chip
>    Documentation: Bindings: Add STM32 DWMAC glue
>    net: ethernet: stmmac: add support of Synopsys 3.50a MAC IP
>    ARM: STM32: Enable Ethernet in stm32_defconfig
>
>   .../devicetree/bindings/net/stm32-dwmac.txt        |  40 +++++
>   arch/arm/configs/stm32_defconfig                   |   9 +
>   drivers/net/ethernet/stmicro/stmmac/Kconfig        |  12 ++
>   drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>   drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c  | 193 +++++++++++++++++++++
>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   1 +
>   6 files changed, 256 insertions(+)
>   create mode 100644 Documentation/devicetree/bindings/net/stm32-dwmac.txt
>   create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
>
