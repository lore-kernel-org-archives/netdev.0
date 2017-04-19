From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 1/4] dt-bindings: net: Add TI WiLink shared transport binding
Date: Wed, 19 Apr 2017 15:49:28 -0500
Message-ID: <CAL_JsqLdeVnYRROmgj37Yh09h9eHtPWT8UhS_uTwjGj2FT2TYQ@mail.gmail.com>
References: <20170413150353.7389-1-robh@kernel.org> <20170413150353.7389-2-robh@kernel.org>
 <CAHCN7x+HhwmXGxZn_31LuzdkEdoAnOSxukAdXULrGbSeKmrtRQ@mail.gmail.com>
 <CAHCN7xLHZmS_3+JygQgRxi_tX0mXL22D1Nj9T8jkrMz3-8eQDg@mail.gmail.com> <CAHCN7x+G_jbQTDfyPBZ4Er8vz46tEojrWf29Eztq56c9zBnMeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Wei Xu <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Satish Patel <satish.patel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Adam Ford <aford173-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHCN7x+G_jbQTDfyPBZ4Er8vz46tEojrWf29Eztq56c9zBnMeA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 16, 2017 at 9:09 AM, Adam Ford <aford173-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
>
> On Apr 13, 2017 10:04 AM, "Rob Herring" <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>
> Add serial slave device binding for the TI WiLink series of Bluetooth/FM/GPS
> devices.
>
> Signed-off-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
> v3:
> - rebase on bluetooth-next
>
>  .../devicetree/bindings/net/ti,wilink-st.txt       | 35
> ++++++++++++++++++++++
>  1 file changed, 35 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/ti,wilink-st.txt
>
> diff --git a/Documentation/devicetree/bindings/net/ti,wilink-st.txt
> b/Documentation/devicetree/bindings/net/ti,wilink-st.txt
> new file mode 100644
> index 000000000000..cbad73a84ac4
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/ti,wilink-st.txt
> @@ -0,0 +1,35 @@
> +TI WiLink 7/8 (wl12xx/wl18xx) Shared Transport BT/FM/GPS devices
> +
> +TI WiLink devices have a UART interface for providing Bluetooth, FM radio,
> +and GPS over what's called "shared transport". The shared transport is
> +standard BT HCI protocol with additional channels for the other functions.
> +
> +These devices also have a separate WiFi interface as described in
> +wireless/ti,wlcore.txt.
> +
> +This bindings follows the UART slave device binding in
> +../serial/slave-device.txt.
> +
> +Required properties:
> + - compatible: should be one of the following:
> +    "ti,wl1271-st"
> +    "ti,wl1273-st"
> +    "ti,wl1831-st"
> +    "ti,wl1835-st"
> +    "ti,wl1837-st"
> +
>
>
> Would you expect the wl1283 chipset too?

Probably, but I left it out as there's no public information.

> I can help test this if you like after the holiday weekend. I have a board
> with WL1283 and currently using pdata-quirks to support it.
