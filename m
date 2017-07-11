From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] dt-bindings: net: ravb : Add support for r8a7743 SoC
Date: Tue, 11 Jul 2017 15:12:14 +0300
Message-ID: <52eb0b92-5d25-e1f4-df54-e4fcf648c90e@cogentembedded.com>
References: <20170710012024.j4cso2jyi6canws2@rob-hp-laptop>
 <1499700776-54504-1-git-send-email-biju.das@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Chris Paterson <chris.paterson2@renesas.com>,
        devicetree@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Biju Das <biju.das@bp.renesas.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33392 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755467AbdGKMMT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 08:12:19 -0400
Received: by mail-lf0-f50.google.com with SMTP id z78so83380442lff.0
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2017 05:12:19 -0700 (PDT)
In-Reply-To: <1499700776-54504-1-git-send-email-biju.das@bp.renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 07/10/2017 06:32 PM, Biju Das wrote:

> Add a new compatible string for the RZ/G1M (R8A7743) SoC.
>
> Signed-off-by: Biju Das <biju.das@bp.renesas.com>
> ---
> v1->v2
> * Changed the subject
> * re-formatted the required properties
>
>  .../devicetree/bindings/net/renesas,ravb.txt       | 29 +++++++++++++---------
>  1 file changed, 17 insertions(+), 12 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> index b519503..4717bc2 100644
> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> @@ -4,19 +4,24 @@ This file provides information on what the device node for the Ethernet AVB
>  interface contains.
>
>  Required properties:
> -- compatible: "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.
> -	      "renesas,etheravb-r8a7791" if the device is a part of R8A7791 SoC.
> -	      "renesas,etheravb-r8a7792" if the device is a part of R8A7792 SoC.
> -	      "renesas,etheravb-r8a7793" if the device is a part of R8A7793 SoC.
> -	      "renesas,etheravb-r8a7794" if the device is a part of R8A7794 SoC.
> -	      "renesas,etheravb-r8a7795" if the device is a part of R8A7795 SoC.
> -	      "renesas,etheravb-r8a7796" if the device is a part of R8A7796 SoC.
> -	      "renesas,etheravb-rcar-gen2" for generic R-Car Gen 2 compatible interface.
> -	      "renesas,etheravb-rcar-gen3" for generic R-Car Gen 3 compatible interface.
> +- compatible: Must contain one or more of the following:

    No, it can't contain more than one SoC specific value.

> +      - "renesas,etheravb-r8a7743" for the R8A7743 SoC.
> +      - "renesas,etheravb-r8a7790" for the R8A7790 SoC.
> +      - "renesas,etheravb-r8a7791" for the R8A7791 SoC.
> +      - "renesas,etheravb-r8a7792" for the R8A7792 SoC.
> +      - "renesas,etheravb-r8a7793" for the R8A7793 SoC.
> +      - "renesas,etheravb-r8a7794" for the R8A7794 SoC.
> +      - "renesas,etheravb-rcar-gen2" as a fallback for the above
> +		R-Car Gen2 and RZ/G1 devices.
>
> -	      When compatible with the generic version, nodes must list the
> -	      SoC-specific version corresponding to the platform first
> -	      followed by the generic version.
> +      - "renesas,etheravb-r8a7795" for the R8A7795 SoC.
> +      - "renesas,etheravb-r8a7796" for the R8A7796 SoC.

    Neither here.

> +      - "renesas,etheravb-rcar-gen3" as a fallback for the above
> +		R-Car Gen3 devices.
> +
> +	When compatible with the generic version, nodes must list the
> +	SoC-specific version corresponding to the platform first followed by
> +	the generic version.
>
>  - reg: offset and length of (1) the register block and (2) the stream buffer.
>  - interrupts: A list of interrupt-specifiers, one for each entry in

WBR, Sergei
