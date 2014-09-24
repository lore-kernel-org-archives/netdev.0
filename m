From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v1 3/5] dtb: Add 10GbE node to APM X-Gene SoC device tree
Date: Wed, 24 Sep 2014 17:24:13 +0400
Message-ID: <5422C5FD.6010507@cogentembedded.com>
References: <1411530688-2939-1-git-send-email-isubramanian@apm.com> <1411530688-2939-4-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kchudgar@apm.com, patches@apm.com
To: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:41205 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbaIXNYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 09:24:35 -0400
Received: by mail-lb0-f179.google.com with SMTP id 10so9923399lbg.24
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 06:24:34 -0700 (PDT)
In-Reply-To: <1411530688-2939-4-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/24/2014 7:51 AM, Iyappan Subramanian wrote:

> Added 10GbE interface and clock nodes.

> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

[...]

> diff --git a/arch/arm64/boot/dts/apm-storm.dtsi b/arch/arm64/boot/dts/apm-storm.dtsi
> index c0aceef..ae814ef 100644
> --- a/arch/arm64/boot/dts/apm-storm.dtsi
> +++ b/arch/arm64/boot/dts/apm-storm.dtsi
[...]
> @@ -421,5 +431,19 @@
>
>   			};
>   		};
> +
> +                xgenet: ethernet@1f610000 {
> +			compatible = "apm,xgene-enet";
> +                        status = "disabled";
> +                        reg = <0x0 0x1f610000 0x0 0xd100>,
> +                              <0x0 0x1f600000 0x0 0X400>,
> +                              <0x0 0x18000000 0x0 0X200>;
> +			reg-names = "enet_csr", "ring_csr", "ring_cmd";
> +                        interrupts = <0x0 0x60 0x4>;
> +			dma-coherent;
> +                        clocks = <&xge0clk 0>;
> +                        local-mac-address = [00 01 73 00 00 04];
> +			phy-connection-type = "xgmii";

   Please consistently indent with tabs.

WBR, Sergei
