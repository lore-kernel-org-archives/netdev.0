From: Nelson Chang <nelson.chang@mediatek.com>
Subject: RE: [PATCH net-next 3/3] net: ethernet: mediatek: add dts
 configuration to enable HW LRO
Date: Wed, 14 Sep 2016 13:20:49 +0800
Message-ID: <1473830449.25065.8.camel@mtksdaap41>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>
To: <f.fainelli@gmail.com>, <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:36473 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751676AbcINFUz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 01:20:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resend)

The description of the property as you said is more precise.
The property is a capability if the hardware supports LRO. I'll rephrase
the property description in v2.

Thanks Florian!

-----Original Message-----
From: Florian Fainelli [mailto:f.fainelli@gmail.com]
Sent: Wednesday, September 14, 2016 2:25 AM
To: Nelson Chang (張家祥); john@phrozen.org; davem@davemloft.net
Cc: nbd@openwrt.org; netdev@vger.kernel.org;
linux-mediatek@lists.infradead.org; nelsonch.tw@gmail.com
Subject: Re: [PATCH net-next 3/3] net: ethernet: mediatek: add dts
configuration to enable HW LRO

On 09/13/2016 06:54 AM, Nelson Chang wrote:
> Add the configuration of HW LRO in the binding document.
> 
> Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
> ---
>  Documentation/devicetree/bindings/net/mediatek-net.txt | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt
> b/Documentation/devicetree/bindings/net/mediatek-net.txt
> index 32eaaca..f43c0d1 100644
> --- a/Documentation/devicetree/bindings/net/mediatek-net.txt
> +++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
> @@ -20,6 +20,7 @@ Required properties:
>  - mediatek,ethsys: phandle to the syscon node that handles the port 
> setup
>  - mediatek,pctl: phandle to the syscon node that handles the ports
slew rate
>  	and driver current
> +- mediatek,hwlro: set to enable HW LRO functions of PDMA rx rings

That sounds like implementing a enable/disable policy in the Device Tree
as opposed to providing an indication as to whether the HW supports LRO
or not. If all versions of the hardware support LRO, then you would
rather let the users change NETIF_F_LRO using ethtool features instead
of having this be defined in the Device Tree.

If, on the other hand, not all version of the HW support LRO, then you
would just want to rephrase the property description to say this
describes a capability.
