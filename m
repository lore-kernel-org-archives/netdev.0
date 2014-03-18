From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/3] Documentation: add Device tree bindings for Hisilicon
 hip04 ethernet
Date: Tue, 18 Mar 2014 16:51:04 +0400
Message-ID: <53284138.9030809@cogentembedded.com>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org> <1395132017-15928-2-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org
To: Zhangfei Gao <zhangfei.gao@linaro.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:37782 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754963AbaCRMvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 08:51:04 -0400
Received: by mail-lb0-f176.google.com with SMTP id 10so4700776lbg.35
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 05:51:02 -0700 (PDT)
In-Reply-To: <1395132017-15928-2-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 18-03-2014 12:40, Zhangfei Gao wrote:

> This patch adds the Device Tree bindings for the Hisilicon hip04
> Ethernet controller, including 100M / 1000M controller.

> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
> ---
>   .../bindings/net/hisilicon-hip04-net.txt           |   74 ++++++++++++++++++++
>   1 file changed, 74 insertions(+)
>   create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt

> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
> new file mode 100644
> index 0000000..c918f08
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
> @@ -0,0 +1,74 @@
> +Hisilicon hip04 Ethernet Controller
> +
> +* Ethernet controller node
> +
> +Required properties:
> +- compatible: should be "hisilicon,hip04-mac".
> +- reg: address and length of the register set for the device.
> +- interrupts: interrupt for the device.
> +- port: ppe port number connected to the controller: range from 0 to 31.
> +- speed: 100 (100M) or 1000 (1000M).

    There's standard "max-speed" property for that, see 
Documentation/devicetree/bindings/net/ethernet.txt in the 'net-next.git' repo.

> +Optional Properties:
> +- phy-handle : the phandle to a PHY node

    Please refer instead to the above mentioned file for this standard 
property -- it is already described there. See other binding files as the example.

WBR, Sergei
