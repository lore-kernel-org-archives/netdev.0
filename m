From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 3/3] net: ethernet: mediatek: add the dts
 property to set if TRGMII supported on GMAC0
Date: Thu, 22 Sep 2016 14:28:36 +0300
Message-ID: <b04e14ff-15db-9cc8-9490-204da8c5837d@cogentembedded.com>
References: <1474511636-11644-1-git-send-email-sean.wang@mediatek.com>
 <1474511636-11644-4-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        andrew@lunn.ch, f.fainelli@gmail.com, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com, john@phrozen.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474511636-11644-4-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 9/22/2016 5:33 AM, sean.wang@mediatek.com wrote:

> From: Sean Wang <sean.wang@mediatek.com>
>
> Add the dts property for the capability if TRGMII supported on GAMC0
>
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> ---
>  Documentation/devicetree/bindings/net/mediatek-net.txt | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
> index 6103e55..7111278 100644
> --- a/Documentation/devicetree/bindings/net/mediatek-net.txt
> +++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
> @@ -31,7 +31,10 @@ Optional properties:
>  Required properties:
>  - compatible: Should be "mediatek,eth-mac"
>  - reg: The number of the MAC
> -- phy-handle: see ethernet.txt file in the same directory.
> +- phy-handle: see ethernet.txt file in the same directory and
> +	the phy-mode "trgmii" required being provided when reg

   Since you've modified the generic parser of the "phy-mode" to add your 
"trgmii", you also need to update ethernet.txt...

> +	is equal to 0 and the MAC uses fixed-link to connect
> +	with inernal switch such as MT7530.

   Internal.

[...]

MBR, Sergei
