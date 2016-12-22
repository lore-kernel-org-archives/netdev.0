From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] Fixed status entry in m_can documentation
Date: Thu, 22 Dec 2016 17:14:08 -0600
Message-ID: <20161222231408.drbakherghdegnam@rob-hp-laptop>
References: <20161222104521.20683-1-uvv.mail@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jiri Kosina <trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
        Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
To: "Vyacheslav V. Yurkov" <uvv.mail-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161222104521.20683-1-uvv.mail-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 11:45:21AM +0100, Vyacheslav V. Yurkov wrote:
> Use valid value for 'enabled' in status field
> 
> Signed-off-by: Vyacheslav V. Yurkov <uvv.mail-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/can/m_can.txt | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/can/m_can.txt b/Documentation/devicetree/bindings/net/can/m_can.txt
> index 9e33177..5facaf5 100644
> --- a/Documentation/devicetree/bindings/net/can/m_can.txt
> +++ b/Documentation/devicetree/bindings/net/can/m_can.txt
> @@ -63,5 +63,5 @@ Board dts:
>  &m_can1 {
>  	pinctrl-names = "default";
>  	pinctrl-0 = <&pinctrl_m_can1>;
> -	status = "enabled";
> +	status = "okay";

Examples don't need to have status prop. Just remove.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
