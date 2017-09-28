From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/4] dt-bindings: net: ravb: Document optional reset-gpios
 property
Date: Thu, 28 Sep 2017 23:07:38 +0300
Message-ID: <fefd2be3-d47a-f035-5078-090df0fc6318@cogentembedded.com>
References: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
 <1506614014-4398-2-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1506614014-4398-2-git-send-email-geert+renesas@glider.be>
Content-Language: en-MW
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 09/28/2017 06:53 PM, Geert Uytterhoeven wrote:

> The optional "reset-gpios" property (part of the generic MDIO bus
> properties) lets us describe the GPIO used for resetting the Ethernet
> PHY.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
>   Documentation/devicetree/bindings/net/renesas,ravb.txt | 2 ++
>   1 file changed, 2 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> index c902261893b913f5..4a6ec1ba32d0bf16 100644
> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> @@ -52,6 +52,7 @@ Optional properties:
>   			 AVB_LINK signal.
>   - renesas,ether-link-active-low: boolean, specify when the AVB_LINK signal is
>   				 active-low instead of normal active-high.
> +- reset-gpios: see mdio.txt in the same directory.

    Sigh, I can only repeat that was a terrible prop name choice -- when 
applied to a MAC node... what reset does it mean? MAC?

MBR, Sergei
