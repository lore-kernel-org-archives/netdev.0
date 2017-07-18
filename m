From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [PATCH net-next v2 1/4] dt-bindings: net: mediatek: add support
 for MediaTek MT7623 and MT7622 SoC
Date: Tue, 18 Jul 2017 13:13:33 +0800
Message-ID: <1500354813.19736.7.camel@mtkswgap22>
References: <cover.1500285278.git.sean.wang@mediatek.com>
         <d1e8daa3291f303bd581b89eae6e4003f2ee58a8.1500285278.git.sean.wang@mediatek.com>
         <20170717133811.GA30392@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <john@phrozen.org>, <davem@davemloft.net>, <nbd@openwrt.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170717133811.GA30392@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-07-17 at 15:38 +0200, Andrew Lunn wrote:
> On Mon, Jul 17, 2017 at 06:06:22PM +0800, sean.wang@mediatek.com wrote:
> > From: Sean Wang <sean.wang@mediatek.com>
> > 
> > The patch adds the supplements in the dt-binding document for MediaTek
> > MT7622 SoC with extra SGMII system controller and relevant clock consumers
> > listed as the requirements for those SoCs equipped with the SGMII circuit.
> > Also, add the missing binding information for MT7623 SoC here which relies
> > on the fallback binding of MT2701.
> > 
> > Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> > ---
> >  Documentation/devicetree/bindings/net/mediatek-net.txt | 12 +++++++++---
> >  1 file changed, 9 insertions(+), 3 deletions(-)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
> > index c7194e8..1d1168b 100644
> > --- a/Documentation/devicetree/bindings/net/mediatek-net.txt
> > +++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
> > @@ -7,24 +7,30 @@ have dual GMAC each represented by a child node..
> >  * Ethernet controller node
> >  
> >  Required properties:
> > -- compatible: Should be "mediatek,mt2701-eth"
> > +- compatible: Should be
> > +		"mediatek,mt2701-eth": for MT2701 SoC
> > +		"mediatek,mt7623-eth", "mediatek,mt2701-eth": for MT7623 SoC
> 
> Hi Sean
> 
> We appear to have "mediatek,mt2701-eth" twice.
> 

Hi, Andrew

mt7623-eth supported up to now currently rely on the fallback binding of
mt2701-eth

in fact, the logic could be commonly found in many driver such as mtk
sysirq such as [1] did, so i felt this usage should not make something
wrong.


[1] https://patchwork.kernel.org/patch/9739827/


>    Andrew
