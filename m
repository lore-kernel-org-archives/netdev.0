From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/3] net: Add MDIO bus driver for the Hisilicon FEMAC
Date: Tue, 14 Jun 2016 17:27:46 -0500
Message-ID: <20160614222746.GA4322@rob-hp-laptop>
References: <1465798076-176393-1-git-send-email-lidongpo@hisilicon.com>
 <1465798076-176393-2-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, mark.rutland@arm.com, davem@davemloft.net,
	xuejiancheng@hisilicon.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dongpo Li <lidongpo@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465798076-176393-2-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2016 at 02:07:54PM +0800, Dongpo Li wrote:
> This patch adds a separate driver for the MDIO interface of the
> Hisilicon Fast Ethernet MAC.
> 
> Reviewed-by: Jiancheng Xue <xuejiancheng@hisilicon.com>
> Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
> ---
>  .../bindings/net/hisilicon-femac-mdio.txt          |  22 +++

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/net/phy/Kconfig                            |   8 +
>  drivers/net/phy/Makefile                           |   1 +
>  drivers/net/phy/mdio-hisi-femac.c                  | 165 +++++++++++++++++++++
>  4 files changed, 196 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/hisilicon-femac-mdio.txt
>  create mode 100644 drivers/net/phy/mdio-hisi-femac.c
