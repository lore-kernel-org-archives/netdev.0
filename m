From: Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/5] Documentation: devicetree: sja1000: add reg-io-width binding
Date: Thu, 30 Jan 2014 08:45:17 -0600
Message-ID: <CAL_JsqJiQ070Pe1h43KkSY+AEY7mO52-xvBK06PFj+gRji86MA@mail.gmail.com>
References: <1391092168-21246-1-git-send-email-florian.vaussard@epfl.ch>
	<1391092168-21246-5-git-send-email-florian.vaussard@epfl.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Florian Vaussard <florian.vaussard-p8DiymsW2f8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1391092168-21246-5-git-send-email-florian.vaussard-p8DiymsW2f8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 30, 2014 at 8:29 AM, Florian Vaussard
<florian.vaussard-p8DiymsW2f8@public.gmane.org> wrote:
> Add the reg-io-width property to describe the width of the memory
> accesses.
>
> Cc: Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>
> Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
> Cc: Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
> Cc: Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Florian Vaussard <florian.vaussard-p8DiymsW2f8@public.gmane.org>

Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

> ---
>  Documentation/devicetree/bindings/net/can/sja1000.txt | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/Documentation/devicetree/bindings/net/can/sja1000.txt b/Documentation/devicetree/bindings/net/can/sja1000.txt
> index f2105a4..b4a6d53 100644
> --- a/Documentation/devicetree/bindings/net/can/sja1000.txt
> +++ b/Documentation/devicetree/bindings/net/can/sja1000.txt
> @@ -12,6 +12,10 @@ Required properties:
>
>  Optional properties:
>
> +- reg-io-width : Specify the size (in bytes) of the IO accesses that
> +       should be performed on the device.  Valid value is 1, 2 or 4.
> +       Default to 1 (8 bits).
> +
>  - nxp,external-clock-frequency : Frequency of the external oscillator
>         clock in Hz. Note that the internal clock frequency used by the
>         SJA1000 is half of that value. If not specified, a default value
> --
> 1.8.1.2
>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
