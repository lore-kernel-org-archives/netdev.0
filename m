From: Rob Herring <robh+dt@kernel.org>
Subject: Re: [PATCH v2 1/2] devicetree: add binding for Aurora VLSI NB8800
 Ethernet controller
Date: Thu, 22 Oct 2015 13:07:45 -0500
Message-ID: <CAL_Jsq+aiDjoCHASFeMdR8ndJ1zv3UCC3vOBSoKS_sfaPv6_DQ@mail.gmail.com>
References: <1445531330-17461-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Mans Rullgard <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445531330-17461-1-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 11:28 AM, Mans Rullgard <mans@mansr.com> wrote:
> This adds a binding for the Aurora VLSI NB8800 Ethernet controller
> using the "aurora,nb8800" compatible string.  When used in Sigma
> Designs chips a few additional control registers are available.
> This variant is indicated by the "sigma,smp8640-ethernet" compatible
> string.
>
> Signed-off-by: Mans Rullgard <mans@mansr.com>

Acked-by: Rob Herring <robh@kernel.org>

> ---
> Changes:
> - correct order of compatible strings
> ---
>  .../devicetree/bindings/net/aurora,nb8800.txt      | 26 ++++++++++++++++++++++
>  1 file changed, 26 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/aurora,nb8800.txt
>
> diff --git a/Documentation/devicetree/bindings/net/aurora,nb8800.txt b/Documentation/devicetree/bindings/net/aurora,nb8800.txt
> new file mode 100644
> index 0000000..cf7108d
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/aurora,nb8800.txt
> @@ -0,0 +1,26 @@
> +* Aurora VLSI AU-NB8800 Ethernet controller
> +
> +Required properties:
> +- compatible: Should be "sigma,smp8640-ethernet", "aurora,nb8800"
> +       The former indicates presence of extra features added by Sigma Designs.
> +- reg: Should be MMIO address space of the device
> +- interrupts: Should contain the interrupt specifier for the device
> +- interrupt-parent: Should be a phandle for the interrupt controller
> +- clocks: Should be a phandle for the clock for the device
> +
> +Common properties described in ethernet.txt:
> +- local-mac-address
> +- mac-address
> +- max-speed
> +- phy-mode
> +
> +Example:
> +
> +ethernet@26000 {
> +       compatible = "aurora,nb8800";
> +       reg = <0x10000 0x800>;
> +       interrupts = <42>;
> +       clocks = <&sys_clk>;
> +       max-speed = <1000>;
> +       phy-connection-type = "rgmii";
> +};
> --
> 2.5.3
>
