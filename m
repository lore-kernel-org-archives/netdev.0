From: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [PATCH 3/3] net: smsc911x: add u16 workaround for pxa platforms
Date: Mon, 3 Oct 2016 16:46:25 +0100
Message-ID: <20161003154624.GG7632@leverpostej>
References: <1475485553-18747-1-git-send-email-robert.jarzmik@free.fr>
 <1475485553-18747-3-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Nicolas Pitre <nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org>,
        Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1475485553-18747-3-git-send-email-robert.jarzmik-GANU6spQydw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 03, 2016 at 11:05:53AM +0200, Robert Jarzmik wrote:
> Add a workaround for mainstone, idp and stargate2 boards, for u16 writes
> which must be aligned on 32 bits addresses.
> 
> Signed-off-by: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/smsc911x.txt | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/smsc911x.txt b/Documentation/devicetree/bindings/net/smsc911x.txt
> index 3fed3c124411..224965b7453c 100644
> --- a/Documentation/devicetree/bindings/net/smsc911x.txt
> +++ b/Documentation/devicetree/bindings/net/smsc911x.txt
> @@ -13,6 +13,8 @@ Optional properties:
>  - reg-io-width : Specify the size (in bytes) of the IO accesses that
>    should be performed on the device.  Valid value for SMSC LAN is
>    2 or 4.  If it's omitted or invalid, the size would be 2.
> +- reg-u16-align4 : Boolean, put in place the workaround the force all
> +  		   u16 writes to be 32 bits aligned

This property name and description is confusing.

How exactly does this differ from having reg-io-width = <4>, which is
documented immediately above?

Thanks,
Mark.

>  - smsc,irq-active-high : Indicates the IRQ polarity is active-high
>  - smsc,irq-push-pull : Indicates the IRQ type is push-pull
>  - smsc,force-internal-phy : Forces SMSC LAN controller to use
> -- 
> 2.1.4
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
