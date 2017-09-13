From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] dt-bindings: net: renesas-ravb: Add support for R8A77995
 RAVB
Date: Wed, 13 Sep 2017 19:02:05 +0300
Message-ID: <1f4763ea-9f8a-03a6-1215-69b96c404590@cogentembedded.com>
References: <1505305060-4192-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        devicetree@vger.kernel.org
To: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
        davem@davemloft.net, robh+dt@kernel.org, mark.rutland@arm.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1505305060-4192-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
Content-Language: en-MW
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 09/13/2017 03:17 PM, Yoshihiro Shimoda wrote:

> Add a new compatible string for the R8A77995 (R-Car D3) RAVB.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> ---
>   Documentation/devicetree/bindings/net/renesas,ravb.txt | 1 +
>   1 file changed, 1 insertion(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> index 1672353..ae2213f 100644
> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> @@ -17,6 +17,7 @@ Required properties:
>   
>         - "renesas,etheravb-r8a7795" for the R8A7795 SoC.
>         - "renesas,etheravb-r8a7796" for the R8A7796 SoC.
> +      - "renesas,etheravb-r8a77995" for the R8A77995 SoC.

    That would conflict with the R8A77970 bindings patch posted by me 
yesterday. Please respin atop of it.

>         - "renesas,etheravb-rcar-gen3" as a fallback for the above
>   		R-Car Gen3 devices.
>   

    One more fragment is needed here, about the mandatory 'interrupt-names" 
prop. My patch makes this change unnecessary, however...

MBR, Sergei
