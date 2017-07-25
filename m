From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] dt-bindings: add device tree binding for Allwinner XR819 SDIO Wi-Fi
Date: Tue, 25 Jul 2017 16:14:28 +0300
Message-ID: <87bmo8irpn.fsf@codeaurora.org>
References: <20170718072940.17872-1-icenowy@aosc.io>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170718072940.17872-1-icenowy-h8G6r0blFSE@public.gmane.org> (Icenowy Zheng's message
        of "Tue, 18 Jul 2017 15:29:40 +0800")
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org> writes:

> Allwinner XR819 is a SDIO Wi-Fi chip, which has the functionality to use
> an out-of-band interrupt pin instead of SDIO in-band interrupt.
>
> Add the device tree binding of this chip, in order to make it possible
> to add this interrupt pin to device trees.
>
> Signed-off-by: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
> ---
>  .../bindings/net/wireless/allwinner,xr819.txt      | 37 ++++++++++++++++++++++
>  1 file changed, 37 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt
>
> diff --git
> a/Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt
> b/Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt
> new file mode 100644
> index 000000000000..64dd9c1c0584
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt
> @@ -0,0 +1,37 @@
> +Allwinner XRadio wireless SDIO devices
> +
> +This node provides properties for controlling the XRadio wireless device. The
> +node is expected to be specified as a child node to the SDIO controller that
> +connects the device to the system.
> +
> +Required properties:
> +
> + - compatible : Should be "allwinner,xr819".
> +
> +Optional properties:
> + - interrupt-parent : the phandle for the interrupt controller to which the
> +	device interrupts are connected.
> + - interrupts : specifies attributes for the out-of-band interrupt (host-wake).
> +	When not specified the device will use in-band SDIO interrupts.

Where is the driver which uses this? I don't see it in
drivers/net/wireless but I guess that's not a blocker for the bindings?

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
