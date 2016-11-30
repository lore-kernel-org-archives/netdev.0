From: Jan =?ISO-8859-1?Q?L=FCbbe?= <jlu@pengutronix.de>
Subject: Re: [PATCH 4/6] net: ethernet: ti: cpts: add ptp pps support
Date: Wed, 30 Nov 2016 12:01:26 +0100
Message-ID: <1480503686.9183.69.camel@pengutronix.de>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
         <20161128230428.6872-5-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org, Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161128230428.6872-5-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mo, 2016-11-28 at 17:04 -0600, Grygorii Strashko wrote:
> --- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
> +++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
> @@ -127,6 +127,16 @@ Optional properties:
>                 The number of external time stamp channels.
>                 The different CPTS versions might support up 8
>                 external time stamp channels. if absent - unsupported.
> +       - cpts-ts-comp-length:
> +               Enable time stamp comparison event and TS_COMP signal output
> +               generation when CPTS counter reaches a value written to
> +               the TS_COMP_VAL register.
> +               The generated pulse width is 3 refclk cycles if this property
> +               has no value (empty) or, otherwise, it should specify desired
> +               pulse width in number of refclk periods - max value 2^16.
> +               TS_COMP functionality will be disabled if not present.
> +       - cpts-ts-comp-polarity-low:
> +               Set polarity of TS_COMP signal to low. Default is hight.

Why is this configured via DT? Are the values fixed for a given board,
depending on external components? Couldn't this be configured somewhere
else?

Regards,
Jan
-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
