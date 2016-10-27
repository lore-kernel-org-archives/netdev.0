From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/5] Documentation: devicetree: net: add NS2 bindings to
 amac
Date: Thu, 27 Oct 2016 11:17:57 +0200
Message-ID: <20161027091757.GC12841@lunn.ch>
References: <1477510561-17035-1-git-send-email-jon.mason@broadcom.com>
 <1477510561-17035-3-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
 bcm-kernel-feedback-list@broadcom.com, rafal@milecki.pl,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1477510561-17035-3-git-send-email-jon.mason@broadcom.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 26, 2016 at 03:35:58PM -0400, Jon Mason wrote:
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> ---
>  Documentation/devicetree/bindings/net/brcm,amac.txt | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/brcm,amac.txt b/Documentation/devicetree/bindings/net/brcm,amac.txt
> index ba5ecc1..f92caee 100644
> --- a/Documentation/devicetree/bindings/net/brcm,amac.txt
> +++ b/Documentation/devicetree/bindings/net/brcm,amac.txt
> @@ -2,15 +2,18 @@ Broadcom AMAC Ethernet Controller Device Tree Bindings
>  -------------------------------------------------------------
>  
>  Required properties:
> - - compatible:	"brcm,amac" or "brcm,nsp-amac"
> + - compatible:	"brcm,amac", "brcm,nsp-amac", or "brcm,ns2-amac"
>   - reg:		Address and length of the GMAC registers,
>  		Address and length of the GMAC IDM registers
> +		Address and length of the NIC Port Manager registers (optional)
>   - reg-names:	Names of the registers.  Must have both "amac_base" and
> -		"idm_base"
> +		"idm_base". "nicpm_base" is optional (required for NS2)
>   - interrupts:	Interrupt number
>  
>  Optional properties:
>  - mac-address:	See ethernet.txt file in the same directory
> +- brcm,enet-phy-lane-swap:
> +		boolean; Swap the PHY lanes (needed on some SKUs of NS2)

Maybe i'm missing something here, but the patch to the PHY swapped the
lanes. This seems to be a PHY property, not a MAC property. And it
swapped them unconditionally....

	Andrew
