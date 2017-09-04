From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v3 2/3] dt-binding: net: sfp binding documentation
Date: Mon, 4 Sep 2017 12:59:29 +0300
Message-ID: <d7eb151f-0967-7ffb-91a1-5e27f9db4050@cogentembedded.com>
References: <c2a27566a8eb358ee2566a213c385d0bf3d64307.1504441874.git.baruch@tkos.co.il>
 <01ae7bc45d68322669d18a4feeaeef733ba888d7.1504441874.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <01ae7bc45d68322669d18a4feeaeef733ba888d7.1504441874.git.baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello!

On 9/3/2017 3:31 PM, Baruch Siach wrote:

> Add device-tree binding documentation SFP transceivers. Support for SFP
> transceivers has been recently introduced (drivers/net/phy/sfp.c).
> 
> Signed-off-by: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
[...]
> diff --git a/Documentation/devicetree/bindings/net/sff,sfp.txt b/Documentation/devicetree/bindings/net/sff,sfp.txt
> new file mode 100644
> index 000000000000..b98ee5945265
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/sff,sfp.txt
> @@ -0,0 +1,78 @@
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
> +
> +- moddef0-gpios : GPIO phandle and a single specifier of the MOD-DEF0 (AKA

    There's always a single specifier following a phandle, tho it may have 
different # of cells, no need to spell that out.

> +  Mod_ABS) module presence input gpio signal, active (module absent) high
> +
> +- los-gpios : GPIO phandle and a single specifier of the Receiver Loss of

    Same here.

> +  Signal Indication input gpio signal, active (signal lost) high
> +
> +- tx-fault-gpios : GPIO phandle and a single specifier of the Module

    And here.

> +  Transmitter Fault input gpio signal, active (fault condition) high
> +
> +- tx-disable-gpios : GPIO phandle and a single specifier of the Transmitter

    And here.

> +  Disable output gpio signal, active (Tx disable) high
> +
> +- rate-select0-gpios : GPIO phandle and a single specifier of the Rx Signaling

    Here too.

> +  Rate Select (AKA RS0) output gpio signal, low: low Rx rate, high: high Rx
> +  rate
> +
> +- rate-select1-gpios : GPIO phandle and a single specifier of the Tx Signaling

    Here ass well.

> +  Rate Select (AKA RS1) output gpio signal (SFP+ only), low: low Tx rate,
> +  high: high Tx rate
> +
[...]

MBR, Sergei
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
