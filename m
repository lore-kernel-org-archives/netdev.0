From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net v4 2/3] dt-binding: net: sfp binding documentation
Date: Mon, 30 Oct 2017 20:13:42 -0700
Message-ID: <d707abea-a9eb-74d0-841f-1ff1fe4153a8@gmail.com>
References: <b98ac3e8cde5c99489e8dcee9a1d5b8a19face8d.1504776350.git.baruch@tkos.co.il>
 <5b46343b543ad1d2ebbc5be9871def7f92c4dbd8.1504776350.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5b46343b543ad1d2ebbc5be9871def7f92c4dbd8.1504776350.git.baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Baruch,

On 09/07/2017 02:25 AM, Baruch Siach wrote:
> Add device-tree binding documentation SFP transceivers. Support for SFP
> transceivers has been recently introduced (drivers/net/phy/sfp.c).
> 
> Signed-off-by: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
> ---
> v4:
>   Remove redundant 'single' from the gpio specifier
>   Rename 'moddef0-gpios' property to 'mod-def0-gpios'
>   Remove 'phy-mode' property from the example; SFP determines the mode
> 
> v3:
>   Mention gpios phandle and specifier
>   Mention the polarity of each gpio
>   Fix example property names
> 
> v2:
>   Rename -gpio properties to -gpios
>   Rename the rate-select-gpio property to rate-select0-gpios
>   Add the rate-select1-gpios property
>   Add examples
> ---
>  Documentation/devicetree/bindings/net/sff,sfp.txt | 76 +++++++++++++++++++++++
>  1 file changed, 76 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/sff,sfp.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/sff,sfp.txt b/Documentation/devicetree/bindings/net/sff,sfp.txt
> new file mode 100644
> index 000000000000..60e970ce10ee
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/sff,sfp.txt
> @@ -0,0 +1,76 @@
> +Small Form Factor (SFF) Committee Small Form-factor Pluggable (SFP)
> +Transceiver
> +
> +Required properties:
> +
> +- compatible : must be "sff,sfp"
> +
> +Optional Properties:
> +
> +- i2c-bus : phandle of an I2C bus controller for the SFP two wire serial
> +  interface

What was the reasoning behind using this property instead of making the
SFP a child of the i2c bus directly? Were you thinking that there could
be systems where the SFP is not i2c-addresable, but another 2-wire
protocol is used instead? This is not particularly wrong per-se I guess,
but usually, the parent/child relationship should make that more obvious.

Right now, we have to have a series of platform devices matching
sff,sfp, so that puts some constraints on where these devices can be
within a Device Tree.

Sorry for catching up on this so late...

Thanks!
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
