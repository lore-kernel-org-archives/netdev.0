From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: stmmac: TX and RX queue priority
 configuration
Date: Thu, 16 Mar 2017 09:55:37 -0700
Message-ID: <c68496fb-761e-5f96-17d4-b32c9ed04be2@gmail.com>
References: <cover.1489661229.git.jpinto@synopsys.com>
 <d4f473fe775aef91382a1ce93aa9234631446daf.1489661229.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36555 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754642AbdCPQzs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 12:55:48 -0400
Received: by mail-wr0-f194.google.com with SMTP id l37so6623685wrc.3
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 09:55:47 -0700 (PDT)
In-Reply-To: <d4f473fe775aef91382a1ce93aa9234631446daf.1489661229.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2017 03:56 AM, Joao Pinto wrote:
> This patch adds the configuration of RX and TX queues' priority.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
>  Documentation/devicetree/bindings/net/stmmac.txt   |  5 +++
>  drivers/net/ethernet/stmicro/stmmac/common.h       |  4 ++
>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h       | 13 ++++++
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 37 +++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 48 ++++++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  4 ++
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 16 ++++++++
>  include/linux/stmmac.h                             |  4 ++
>  8 files changed, 131 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index a7b0e41..b9a9ae9 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -83,6 +83,7 @@ Optional properties:
>  			- snps,dcb-algorithm: Queue to be enabled as DCB
>  			- snps,avb-algorithm: Queue to be enabled as AVB
>  		- snps,map-to-dma-channel: Channel to map
> +	- snps,priority: RX queue priority

You need to be more verbose about how this property is constructed and
what are the acceptable values: type, size, range.
-- 
Florian
