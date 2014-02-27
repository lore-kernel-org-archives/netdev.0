From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] phy: micrel: add of configuration for LED mode
Date: Thu, 27 Feb 2014 09:15:06 +0000
Message-ID: <20140227091505.GA6945@e106331-lin.cambridge.arm.com>
References: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@lists.codethink.co.uk"
	<linux-kernel@lists.codethink.co.uk>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:48307 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752109AbaB0JPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 04:15:10 -0500
Content-Disposition: inline
In-Reply-To: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 26, 2014 at 11:48:00AM +0000, Ben Dooks wrote:
> Add support for the led-mode property for the following PHYs
> which have a single LED mode configuration value.
> 
> KSZ8001 and KSZ8041 which both use register 0x1e bits 15,14 and
> KSZ8021, KSZ8031 and KSZ8051 which use register 0x1f bits 5,4
> to control the LED configuration.
> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> ---
>  Documentation/devicetree/bindings/net/micrel.txt | 18 +++++++++
>  drivers/net/phy/micrel.c                         | 49 ++++++++++++++++++++++--
>  2 files changed, 63 insertions(+), 4 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/micrel.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
> new file mode 100644
> index 0000000..98a3e61
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/micrel.txt
> @@ -0,0 +1,18 @@
> +Micrel PHY properties.
> +
> +These properties cover the base properties Micrel PHYs.
> +
> +Optional properties:
> +
> + - micrel,led-mode : LED mode value to set for PHYs with configurable LEDs.
> +
> +              Configure the LED mode with single value. The list of PHYs and
> +	      the bits that are currently supported:
> +
> +	      KSZ8001: register 0x1e, bits 15..14
> +	      KSZ8041: register 0x1e, bits 15..14
> +	      KSZ8021: register 0x1f, bits 5..4
> +	      KSZ8031: register 0x1f, bits 5..4
> +	      KSZ8051: register 0x1f, bits 5..4
> +
> +              See the respective PHY datasheet for the mode values.

What do these mean, roughly,, and why can the kernel not decide how to
cnofigure these?

In general we prefer to not place raw register values in the DT, and I'd
like to know why we'd have to here.

Cheers,
Mark.
