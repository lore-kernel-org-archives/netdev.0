From: James Liao <jamesjj.liao@mediatek.com>
Subject: Re: [PATCH 1/2] Documentation: devicetree: change the mediatek
 ethernet compatible string
Date: Thu, 2 Feb 2017 13:07:07 +0800
Message-ID: <1486012027.25978.0.camel@mtksdaap41>
References: <1485332455-34743-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sean Wang <sean.wang@mediatek.com>,
        <linux-mediatek@lists.infradead.org>, <devicetree@vger.kernel.org>
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:13710 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750861AbdBBFHO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 00:07:14 -0500
In-Reply-To: <1485332455-34743-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-25 at 09:20 +0100, John Crispin wrote:
> When the binding was defined, I was not aware that mt2701 was an earlier
> version of the SoC. For sake of consistency, the ethernet driver should
> use mt2701 inside the compat string as this is the earliest SoC with the
> ethernet core.
> 
> The ethernet driver is currently of no real use until we finish and
> upstream the DSA driver. There are no users of this binding yet. It should
> be safe to fix this now before it is too late and we need to provide
> backward compatibility for the mt7623-eth compat string.
> 
> Reported-by: Sean Wang <sean.wang@mediatek.com>
> Signed-off-by: John Crispin <john@phrozen.org>

Acked-by: James Liao <jamesjj.liao@mediatek.com>

> ---
>  Documentation/devicetree/bindings/net/mediatek-net.txt |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
> index c010faf..c7194e8 100644
> --- a/Documentation/devicetree/bindings/net/mediatek-net.txt
> +++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
> @@ -7,7 +7,7 @@ have dual GMAC each represented by a child node..
>  * Ethernet controller node
>  
>  Required properties:
> -- compatible: Should be "mediatek,mt7623-eth"
> +- compatible: Should be "mediatek,mt2701-eth"
>  - reg: Address and length of the register set for the device
>  - interrupts: Should contain the three frame engines interrupts in numeric
>  	order. These are fe_int0, fe_int1 and fe_int2.
