From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/3] Documentation: add Device tree bindings for Hisilicon
 hip04 ethernet
Date: Fri, 21 Mar 2014 21:22:40 +0300
Message-ID: <532C8370.8000602@cogentembedded.com>
References: <1395414570-25515-1-git-send-email-zhangfei.gao@linaro.org> <1395414570-25515-2-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Zhangfei Gao <zhangfei.gao@linaro.org>,
	"David S. Miller" <davem@davemloft.net>, linux@arm.linux.org.uk,
	arnd@arndb.de, f.fainelli@gmail.com, mark.rutland@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:40582 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933AbaCURWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 13:22:51 -0400
Received: by mail-lb0-f176.google.com with SMTP id 10so1843640lbg.7
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 10:22:50 -0700 (PDT)
In-Reply-To: <1395414570-25515-2-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/21/2014 06:09 PM, Zhangfei Gao wrote:

> This patch adds the Device Tree bindings for the Hisilicon hip04
> Ethernet controller, including 100M / 1000M controller.

> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
> ---
>   .../bindings/net/hisilicon-hip04-net.txt           |  107 ++++++++++++++++++++
>   1 file changed, 107 insertions(+)
>   create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt

> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
> new file mode 100644
> index 0000000..22838b2
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
> @@ -0,0 +1,107 @@
> +Hisilicon hip04 Ethernet Controller
> +
> +* Ethernet controller node
> +
> +Required properties:
> +- compatible: should be "hisilicon,hip04-mac".
> +- reg: address and length of the register set for the device.
> +- interrupts: interrupt for the device.
> +- port-handle: phandle, specifies a reference to a node representing
> +  the connected port
> +- Inherets from ethernet common binding [1]

    Inherits.

> +[1] Documentation/devicetree/bindings/net/ethernet.txt

    Well, this way it's not clear what exactly it iherits as that file 
describes many alternate properties with the same meaning.

> +
> +
> +* Ethernet ppe node:
> +Control rx & tx fifos of all ethernet controllers.
> +Have 2048 recv channels shared by all ethernet controllers, only if no overlap.
> +Each controller's start recv channel is alisa_id * RX_DESC_NUM.
> +
> +Required properties:
> +- #address-cells : Should be <1>
> +- #size-cells : Should be <0>
> +- compatible: "hisilicon,hip04-ppe"
> +- reg: address and length of the register set for the device.
> +
> +==Child node==
> +
> +Required properties:
> +- reg: port physical number, range from 0 to 0x1f
> +
> +
> +* MDIO bus node:
> +
> +Required properties:
> +
> +- compatible: should be "hisilicon,hip04-mdio", "ethernet-phy-ieee802.3-c22".

    I didn't understand what kind of node this is: MDIO bus or PHY? These 
values seem mutually exclusive.

> +- Inherets from MDIO bus node binding [2]

    Inherits.

> +[2] Documentation/devicetree/bindings/net/phy.txt

WBR, Sergei
