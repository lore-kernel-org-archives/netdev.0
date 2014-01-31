From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 1/2] dt: Document a compatible entry for MDIO ethernet Phys
Date: Fri, 31 Jan 2014 14:30:53 -0800
Message-ID: <CAGVrzcYz6m203EwT6exr06mpTdFQDQ3hHwq+WBhLa7zXnAFGAw@mail.gmail.com>
References: <1391205045-1751-1-git-send-email-jgunthorpe@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1391205045-1751-1-git-send-email-jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2014-01-31 Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>:
> This describes a compatible entry of the form:
>   ethernet-phy-idAAAA,BBBB
> Which is modelled after the PCI structured compatible entry
> (pciVVVV,DDDD.SSSS.ssss.RR)
>
> If present the OF core will be able to use this information to
> directly create the correct phy without auto probing the bus.
>
> Signed-off-by: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
> Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Looks good, thanks!

Acked-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> ---
>  Documentation/devicetree/bindings/net/phy.txt | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>
> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
> index 7cd18fb..989122c 100644
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -23,10 +23,18 @@ Optional Properties:
>    assume clause 22. The compatible list may also contain other
>    elements.
>
> +  If the phy's identifier is known then the list may contain an entry
> +  of the form: "ethernet-phy-idAAAA.BBBB" where
> +     AAAA - The value of the 16 bit Phy Identifier 1 register as
> +            4 hex digits. This is the chip vendor OUI bits 3:18
> +     BBBB - The value of the 16 bit Phy Identifier 2 register as
> +            4 hex digits. This is the chip vendor OUI bits 19:24,
> +            followed by 10 bits of a vendor specific ID.
> +
>  Example:
>
>  ethernet-phy@0 {
> -       compatible = "ethernet-phy-ieee802.3-c22";
> +       compatible = "ethernet-phy-id0141.0e90", "ethernet-phy-ieee802.3-c22";
>         linux,phandle = <2452000>;
>         interrupt-parent = <40000>;
>         interrupts = <35 1>;
> --
> 1.8.1.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
