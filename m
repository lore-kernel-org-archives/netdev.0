From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [PATCH v2 5/5] ARM: dts: am33xx: adopt to cpsw changes
Date: Fri, 23 Aug 2013 14:58:52 +0530
Message-ID: <52172B54.8020201@ti.com>
References: <1377247417-27386-1-git-send-email-zonque@gmail.com> <1377247417-27386-6-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <sergei.shtylyov@cogentembedded.com>,
	<davem@davemloft.net>, <ujhelyi.m@gmail.com>,
	<mugunthanvnm@ti.com>, <vaibhav.bedia@ti.com>, <d-gerlach@ti.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:51581 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752840Ab3HWJdW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 05:33:22 -0400
In-Reply-To: <1377247417-27386-6-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 23 August 2013 02:13 PM, Daniel Mack wrote:
> This third memory region just denotes one single register in the CONTROL
> module block. The driver uses that in order to set the correct physical
> ethernet interface modes.
> 
> Also update the compatible string to make use of the am335x specific
> features of the cpsw driver.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> ---
>  arch/arm/boot/dts/am33xx.dtsi | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
> index a785b95..1a1e9dd 100644
> --- a/arch/arm/boot/dts/am33xx.dtsi
> +++ b/arch/arm/boot/dts/am33xx.dtsi
> @@ -446,7 +446,7 @@
>  		};
>  
>  		mac: ethernet@4a100000 {
> -			compatible = "ti,cpsw";
> +			compatible = "ti,am3352-cpsw";

Please keep this as

	compatible = "ti,am3352-cpsw", "ti,cpsw";

so users can upgrade the DTB or kernel independently. Apart from this
the series looks good to me.

Thanks,
Sekhar
