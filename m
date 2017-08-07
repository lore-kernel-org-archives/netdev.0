From: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] of_mdio: use of_property_read_u32_array()
Date: Mon, 7 Aug 2017 09:18:04 -0500
Message-ID: <CAL_JsqKDXAbAVpgMSU39+9mF7MZWQotLUNkjePy9eUsnBs99Vw@mail.gmail.com>
References: <20170804214354.351406407@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170804214354.351406407-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 4, 2017 at 4:43 PM, Sergei Shtylyov
<sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org> wrote:
> The "fixed-link" prop support predated of_property_read_u32_array(), so
> basically had to open-code it. Using the modern API saves 24 bytes of the
> object code (ARM gcc 4.8.5); the only behavior change would be that the
> prop length check is now less strict (however the strict pre-check done
> in of_phy_is_fixed_link() is left intact anyway)...
>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
>
> ---
> The patch is against the 'dt/next' branch of Rob Herring's 'linux-git' repo
> plus the previously posted patch killing the useless local variable in
> of_phy_register_fixed_link().

It shouldn't depend on anything in my tree and David normally takes
of_mdio.c changes.

Reviewed-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

>
>  drivers/of/of_mdio.c |   16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
