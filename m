From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH v2 0/3] adding new glue driver dwmac-dwc-qos-eth
Date: Wed, 4 Jan 2017 14:43:52 +0100
Message-ID: <34837f5b-afb8-92df-f12e-2fa5514558be@axis.com>
References: <cover.1483530191.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <larper@axis.com>, <swarren@nvidia.com>, <treding@nvidia.com>,
        <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:60484 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965355AbdADNn5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 08:43:57 -0500
In-Reply-To: <cover.1483530191.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let's see if patchwork is smart enough to add the tag to the whole series.

Tested-by: Niklas Cassel <niklas.cassel@axis.com>

On 01/04/2017 12:48 PM, Joao Pinto wrote:
> This patch set contains the porting of the synopsys/dwc_eth_qos.c driver
> to the stmmac structure. This operation resulted in the creation of a new
> platform glue driver called dwmac-dwc-qos-eth which was based in the
> dwc_eth_qos as is.
>
> dwmac-dwc-qos-eth inherited dwc_eth_qos DT bindings, to assure that current
> and old users can continue to use it as before. We can see this driver as
> being deprecated, since all new development will be done in stmmac.
>
> Please check each patch for implementation details.
>
> Joao Pinto (3):
>   stmmac: adding DT parameter for LPI tx clock gating
>   stmmac: move stmmac_clk, pclk, clk_ptp_ref and stmmac_rst to platform
>     structure
>   stmmac: adding new glue driver dwmac-dwc-qos-eth
>
>  .../bindings/net/snps,dwc-qos-ethernet.txt         |   3 +
>  Documentation/devicetree/bindings/net/stmmac.txt   |   2 +
>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |   9 +
>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>  drivers/net/ethernet/stmicro/stmmac/common.h       |   3 +-
>  .../ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c    | 200 +++++++++++++++++++++
>  .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   5 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |   1 +
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  |   6 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   5 -
>  .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   4 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  85 ++-------
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  65 ++++++-
>  include/linux/stmmac.h                             |   6 +
>  14 files changed, 314 insertions(+), 81 deletions(-)
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
>
