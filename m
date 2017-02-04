From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH] Documentation: devicetree: Add PHY no lane swap binding
Date: Sat, 4 Feb 2017 18:23:29 +0100
Message-ID: <20170204172329.GA8364@lunn.ch>
References: <1486223267-11875-1-git-send-email-lukma@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jbrunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
        <u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Fabio Estevam <fabio.estevam-3arQi8VN3Tc@public.gmane.org>
To: Lukasz Majewski <lukma-ynQEQJNshbs@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1486223267-11875-1-git-send-email-lukma-ynQEQJNshbs@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 04, 2017 at 04:47:47PM +0100, Lukasz Majewski wrote:
> Add the documentation to avoid PHY lane swapping. This is a boolean
> entry to notify the phy device drivers that the TX/RX lanes NO need

that the TX/RX lanes should not be swapped.

> to be swapped.
> The use case for this binding mostly happens after wrong HW
> configuration of PHY IC during bootstrap.
> 
> Signed-off-by: Lukasz Majewski <lukma-ynQEQJNshbs@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/phy.txt | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
> index fb5056b..5e25bc9 100644
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -39,6 +39,10 @@ Optional Properties:
>  - enet-phy-lane-swap: If set, indicates the PHY will swap the TX/RX lanes to
>    compensate for the board being designed with the lanes swapped.
>  
> +- enet-phy-lane-no-swap: If set, indicates that PHY will disable swap of the
> +  TX/RX lanes. This binding allows the PHY to work correcly after e.g. wrong
> +  bootstrap configuration caused by issues in PCB layout design.
> +

We are leaving it undefined what it means if neither
enet-phy-lane-no-swap nor enet-phy-lane-swap properties are present.
Do we want to define this? That the swap should be left untouched by
the driver?

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
