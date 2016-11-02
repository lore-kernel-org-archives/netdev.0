From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH v5 4/7] Documentation: devicetree: net: add NS2 bindings
 to amac
Date: Wed, 2 Nov 2016 13:24:57 -0400
Message-ID: <20161102172456.GA11881@broadcom.com>
References: <1478106488-11779-1-git-send-email-jon.mason@broadcom.com>
 <1478106488-11779-5-git-send-email-jon.mason@broadcom.com>
 <ab064a45-0172-fa28-4ac6-0d3159a26506@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>, rafal@milecki.pl,
        bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ab064a45-0172-fa28-4ac6-0d3159a26506@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 02, 2016 at 08:18:51PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 11/02/2016 08:08 PM, Jon Mason wrote:
> 
> >Clean-up the documentation to the bgmac-amac driver, per suggestion by
> >Rob Herring, and add details for NS2 support.
> >
> >Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> >---
> > Documentation/devicetree/bindings/net/brcm,amac.txt | 16 +++++++++++-----
> > 1 file changed, 11 insertions(+), 5 deletions(-)
> >
> >diff --git a/Documentation/devicetree/bindings/net/brcm,amac.txt b/Documentation/devicetree/bindings/net/brcm,amac.txt
> >index ba5ecc1..2fefa1a 100644
> >--- a/Documentation/devicetree/bindings/net/brcm,amac.txt
> >+++ b/Documentation/devicetree/bindings/net/brcm,amac.txt
> >@@ -2,11 +2,17 @@ Broadcom AMAC Ethernet Controller Device Tree Bindings
> > -------------------------------------------------------------
> >
> > Required properties:
> >- - compatible:	"brcm,amac" or "brcm,nsp-amac"
> >- - reg:		Address and length of the GMAC registers,
> >-		Address and length of the GMAC IDM registers
> >- - reg-names:	Names of the registers.  Must have both "amac_base" and
> >-		"idm_base"
> >+ - compatible:	"brcm,amac"
> >+		"brcm,nsp-amac"
> >+		"brcm,ns2-amac"
> >+ - reg:		Address and length of the register set for the device. It
> >+		contains the information of registers in the same order as
> >+		described by reg-names
> >+ - reg-names:	Names of the registers.
> >+		"amac_base":	Address and length of the GMAC registers
> >+		"idm_base":	Address and length of the GMAC IDM registers
> >+		"nicpm_base":	Address and length of the NIC Port Manager
> >+				registers (required for Northstar2)
> 
>   Why this "_base" suffix? It looks redundant...

Yes.  Rob Herring pointed out the same thing.  It is ugly, but follows
the existing binding.

Thanks,
Jon


> 
> [...]
> 
> MBR, Sergei
> 
