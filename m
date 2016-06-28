From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC 6/7] dt-bindings: net: bgmac: add bindings documentation for
 bgmac
Date: Tue, 28 Jun 2016 23:11:38 +0300
Message-ID: <340820bf-bb1e-3228-5003-135363ea27b9@cogentembedded.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
 <1467142484-11161-7-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, f.fainelli@gmail.com, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>, zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467142484-11161-7-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/28/2016 10:34 PM, Jon Mason wrote:

> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> ---
>  .../devicetree/bindings/net/brcm,bgmac-enet.txt     | 21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt
>
> diff --git a/Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt b/Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt
> new file mode 100644
> index 0000000..efd36d5
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/brcm,bgmac-enet.txt
> @@ -0,0 +1,21 @@
> +Broadcom GMAC Ethernet Controller Device Tree Bindings
> +-------------------------------------------------------------
> +
> +Required properties:
> + - compatible:	"brcm,bgmac-enet"
> + - reg:		Address and length of the GMAC registers,
> +		Address and length of the GMAC IDM registers
> + - interrupts:	Interrupt number
> +
> +Optional properties:
> +- mac-address:	mac address to be assigned to the device

    Refer to ethernet.txt in the same directory.

> +
> +Examples:
> +
> +gmac0: enet@18022000 {

    The node name should be "ethernet@..." to comply eith the ePAPR standard.

WBR, Sergei
