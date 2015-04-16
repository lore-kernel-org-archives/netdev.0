From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net 0/5] stmmac: Correct flow control configuration
Date: Thu, 16 Apr 2015 09:22:58 +0200
Message-ID: <552F6352.1020601@st.com>
References: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <vbridger@altera.com>
To: Vince Bridgers <vbridger@opensource.altera.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vince

On 4/15/2015 6:17 PM, Vince Bridgers wrote:
> This series of patches corrects flow control configuration for the Synopsys
> GMAC driver.

Thx for these patches

For the series

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

peppe

>
> Flow control is configured based on a configurable receive fifo size. If
> less than 4Kbytes flow control is left disabled and a warning is presented. If
> a receive fifo size is not specified, flow control is left disabled to
> maintain current behavior. Unicast pause detection was disabled, but is now
> enabled. The pause time was modified to be maximum time per a XON/XOFF
> flow control mode of operation.
>
> This patch was tested on an Altera Cyclone 5 and an Altera Arria 10 devkit,
> and verified that flow control operates as expected when enabled.
>
> Please consider this series for inclusion so that flow control will
> function as expected for the Synopsys GMAC controller.
>
> Vince Bridgers (5):
>    stmmac: Add properties for transmit and receive fifo sizes
>    stmmac: Add defines and documentation for enabling flow control
>    stmmac: Read tx-fifo-depth and rx-fifo-depth from the devicetree
>    stmmac: Enable unicast pause frame detect in GMAC Register 6
>    stmmac: Configure Flow Control to work correctly based on rxfifo size
>
>   Documentation/devicetree/bindings/net/ethernet.txt |  6 +++
>   Documentation/devicetree/bindings/net/stmmac.txt   |  4 ++
>   drivers/net/ethernet/stmicro/stmmac/common.h       |  5 ++-
>   drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    | 51 ++++++++++++++++++++++
>   .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |  5 ++-
>   .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    | 26 ++++++++++-
>   drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |  2 +-
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 16 ++++---
>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  4 ++
>   include/linux/stmmac.h                             |  2 +
>   10 files changed, 111 insertions(+), 10 deletions(-)
>
