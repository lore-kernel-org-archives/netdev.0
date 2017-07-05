From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v 1/2] ravb: Add support for r8a7743 SoC
Date: Wed, 5 Jul 2017 16:20:48 +0300
Message-ID: <afcd181c-c805-8f3c-955f-652d001a03d4@cogentembedded.com>
References: <1499259711-56175-1-git-send-email-biju.das@bp.renesas.com>
 <1499259711-56175-2-git-send-email-biju.das@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Chris Paterson <chris.paterson2@renesas.com>,
        devicetree@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Biju Das <biju.das@bp.renesas.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1499259711-56175-2-git-send-email-biju.das@bp.renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 07/05/2017 04:01 PM, Biju Das wrote:

> Add support for Gigabit Ethernet E-MAC on r8a7743 (RZ/G1M) SoC.
> Renesas RZ/G1M (R8A7743) SoC Ethernet AVB IP is identical to the R-Car Gen2
> family.
>
> Signed-off-by: Biju Das <biju.das@bp.renesas.com>
> Reviewed-by: Chris Paterson <chris.paterson2@renesas.com>
[...]
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 5931e85..e35b30f 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -1869,6 +1869,7 @@ static int ravb_mdio_release(struct ravb_private *priv)
>  }
>
>  static const struct of_device_id ravb_match_table[] = {
> +	{ .compatible = "renesas,etheravb-r8a7743", .data = (void *)RCAR_GEN2 },

    No, this shouldn't be needed if you specify "renesas,etheravb-rcar-gen2".

>  	{ .compatible = "renesas,etheravb-r8a7790", .data = (void *)RCAR_GEN2 },
>  	{ .compatible = "renesas,etheravb-r8a7794", .data = (void *)RCAR_GEN2 },
>  	{ .compatible = "renesas,etheravb-rcar-gen2", .data = (void *)RCAR_GEN2 },

MBR, Sergei
