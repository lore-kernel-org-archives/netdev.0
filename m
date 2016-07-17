From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v0 04/10] arm: orion5x: Generalise mv88f5181l pinctrl
 support for 88f5181
Date: Sun, 17 Jul 2016 15:40:14 -0500
Message-ID: <20160717204014.GA16350@rob-hp-laptop>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
 <1468679348-10522-5-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Imre Kaloz <kaloz-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1468679348-10522-5-git-send-email-jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 16, 2016 at 03:29:02PM +0100, Jamie Lentin wrote:
> As far as I'm aware the mv88f5181-b1 and mv88f5181l are the same at the
> pinctrl level, so re-use the definitions for both.
> 
> Signed-off-by: Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
> ---
>  .../bindings/pinctrl/marvell,orion-pinctrl.txt     |  4 ++--
>  drivers/pinctrl/mvebu/pinctrl-orion.c              | 23 +++++++++++-----------
>  2 files changed, 14 insertions(+), 13 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/pinctrl/marvell,orion-pinctrl.txt b/Documentation/devicetree/bindings/pinctrl/marvell,orion-pinctrl.txt
> index 27570a3..5a79bad 100644
> --- a/Documentation/devicetree/bindings/pinctrl/marvell,orion-pinctrl.txt
> +++ b/Documentation/devicetree/bindings/pinctrl/marvell,orion-pinctrl.txt
> @@ -4,8 +4,8 @@ Please refer to marvell,mvebu-pinctrl.txt in this directory for common binding
>  part and usage.
>  
>  Required properties:
> -- compatible: "marvell,88f5181l-pinctrl", "marvell,88f5182-pinctrl",
> -              "marvell,88f5281-pinctrl"
> +- compatible: "marvell,88f5181-pinctrl", "marvell,88f5181l-pinctrl",
> +              "marvell,88f5182-pinctrl", "marvell,88f5281-pinctrl"

Please reformat to one per line. Otherwise,

Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


>  
>  - reg: two register areas, the first one describing the first two
>    contiguous MPP registers, and the second one describing the single
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
