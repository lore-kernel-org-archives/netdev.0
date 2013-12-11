From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 1/2] net: smc91x: Read hardware behavior flags from
 device tree
Date: Wed, 11 Dec 2013 08:04:40 -0800
Message-ID: <20131211160440.GA13171@atomide.com>
References: <1386757305-12545-1-git-send-email-nm@ti.com>
 <1386757305-12545-2-git-send-email-nm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree@vger.kernel.org, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	=?utf-8?Q?Beno=C3=AEt?= Cousson <bcousson@baylibre.com>
To: Nishanth Menon <nm@ti.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386757305-12545-2-git-send-email-nm@ti.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Nishanth Menon <nm@ti.com> [131211 02:23]:
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/smsc91x.txt
> @@ -0,0 +1,45 @@
> +* Smart Mixed-Signal Connectivity (SMSC) LAN91c94/91c111 Controller
> +
> +Required properties:
> +- compatible : Should be one of:
> +	"smsc,lan91c94"
> +	"smsc,lan91c111"
> +- reg : Address and length of the io space for SMSC LAN
> +- interrupts : Should contain SMSC LAN interrupt line
> +- interrupt-parent : Should be the phandle for the interrupt controller
> +  that services interrupts for this device
> +
> +Optional properties:
> +- reg-shift : Specify the quantity to shift the register offsets by
> +- reg-io-width : Specify the size (in bytes) of the IO accesses that
> +  should be performed on the device.  Valid value for SMSC LAN is
> +  1, 2 or 4.

I posted a minimal regression fix for this a few weeks ago that we
should merge to the v3.13-rc cycle:

http://www.spinics.net/lists/netdev/msg258913.html

Care to ack that one? Then if that works for you, maybe rebase these on
that one for the upcoming merge window?

Note that for the -rc cycle we don't need these extra properties as we
can get the interrupts from the struct resource after fix
4a43d686fe336c (of/irq: Pass trigger type in IRQ resource flags)
got merged.

Regards,

Tony
