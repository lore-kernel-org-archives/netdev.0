From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/7] dt-bindings: net: bgmac: add bindings documentation
 for bgmac
Date: Fri, 01 Jul 2016 11:46:04 +0200
Message-ID: <29091648.CIZSyGWL7u@wuerfel>
References: <1467327554-22074-1-git-send-email-jon.mason@broadcom.com>
 <1467327554-22074-7-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 f.fainelli@gmail.com, Scott Branden <sbranden@broadcom.com>,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 hauke@hauke-m.de, zajec5@gmail.com, linux-kernel@vger.kernel.org,
 Ray Jui <rjui@broadcom.com>, Rob Herring <robh+dt@kernel.org>,
 bcm-kernel-feedback-list@broadcom.com, Kumar Gala <galak@codeaurora.org>,
 netdev@vger.kernel.org, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1467327554-22074-7-git-send-email-jon.mason@broadcom.com>
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

On Thursday, June 30, 2016 6:59:13 PM CEST Jon Mason wrote:
> +
> +Required properties:
> + - compatible: "brcm,bgmac-nsp"
> + - reg:                Address and length of the GMAC registers,
> +               Address and length of the GMAC IDM registers
> + - reg-names:  Names of the registers.  Must have both "gmac_base" and
> +               "idm_base"
> + - interrupts: Interrupt number
> +


"brcm,bgmac-nsp" sounds a bit too general. As I understand, this is a family
of SoCs that might not all have the exact same implementation of this
ethernet device, as we can see from the long lookup table in bgmac_probe().

Please document the specific product numbers here that are publically
known already. Having the driver match just on "brcm,bgmac-nsp" as a fallback
is fine, so you can document that one as required for all users.

	Arnd
