From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v2 1/3] net: mvneta: introduce compatible string "marvell,armada-xp-neta"
Date: Mon, 29 Jun 2015 15:03:59 +0200
Message-ID: <5591423F.8060804@free-electrons.com>
References: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org> <1434547162-6275-2-git-send-email-simon.guinot@sequanux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Vincent Donnefort <vdonnefort@gmail.com>,
	stable@vger.kernel.org
To: Simon Guinot <simon.guinot@sequanux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:47935 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751100AbbF2NEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 09:04:01 -0400
In-Reply-To: <1434547162-6275-2-git-send-email-simon.guinot@sequanux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon,

On 17/06/2015 15:19, Simon Guinot wrote:
> The mvneta driver supports the Ethernet IP found in the Armada 370, XP,
> 380 and 385 SoCs. Since at least one more hardware feature is available
> for the Armada XP SoCs then a way to identify them is needed.
> 
> This patch introduces a new compatible string "marvell,armada-xp-neta".
> 
> Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
> Cc: <stable@vger.kernel.org> # v3.8+

Acked-by: Gregory CLEMENT <gregory.clement@free-electrons.com>


Thanks,

Gregory

> ---
>  Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt | 2 +-
>  drivers/net/ethernet/marvell/mvneta.c                             | 1 +
>  2 files changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
> index 750d577e8083..f5a8ca29aff0 100644
> --- a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
> +++ b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
> @@ -1,7 +1,7 @@
>  * Marvell Armada 370 / Armada XP Ethernet Controller (NETA)
>  
>  Required properties:
> -- compatible: should be "marvell,armada-370-neta".
> +- compatible: "marvell,armada-370-neta" or "marvell,armada-xp-neta".
>  - reg: address and length of the register set for the device.
>  - interrupts: interrupt for the device
>  - phy: See ethernet.txt file in the same directory.
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index ce5f7f9cff06..aceb977b104d 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -3179,6 +3179,7 @@ static int mvneta_remove(struct platform_device *pdev)
>  
>  static const struct of_device_id mvneta_match[] = {
>  	{ .compatible = "marvell,armada-370-neta" },
> +	{ .compatible = "marvell,armada-xp-neta" },
>  	{ }
>  };
>  MODULE_DEVICE_TABLE(of, mvneta_match);
> 


-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
