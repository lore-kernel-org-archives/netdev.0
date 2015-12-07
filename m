From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/1] stmmac: socfpga: Provide dt node to config ptp clk
 source.
Date: Mon, 7 Dec 2015 14:57:31 +0300
Message-ID: <5665742B.7090908@cogentembedded.com>
References: <1449452324-53858-1-git-send-email-preid@electromag.com.au>
 <1449452324-53858-3-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Reid <preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449452324-53858-3-git-send-email-preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/07/2015 04:38 AM, Phil Reid wrote:

    How about change log?

> Signed-off-by: Phil Reid <preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org>
> ---
>   Documentation/devicetree/bindings/net/socfpga-dwmac.txt |  2 ++
>   drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c     | 10 ++++++++++
>   2 files changed, 12 insertions(+)
>
> diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> index 3a9d679..72d82d6 100644
> --- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> @@ -11,6 +11,8 @@ Required properties:
>   		  designware version numbers documented in stmmac.txt
>    - altr,sysmgr-syscon : Should be the phandle to the system manager node that
>      encompasses the glue register, the register offset, and the register shift.
> + - altr,f2h_ptp_ref_clk use f2h_ptp_ref_clk instead of default eosc1 clock

    Colon missed after the prop name. And in general, hyphens are preferred to 
underscores in the device tree names.

> +   for ptp ref clk. This affects all emacs as the clock is common.
>
>   Optional properties:
>   altr,emac-splitter: Should be the phandle to the emac splitter soft IP node if
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> index 401383b..c1bab62 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
[...]
> @@ -116,6 +118,9 @@ static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct device *
>   		return -EINVAL;
>   	}
>
> +	dwmac->f2h_ptp_ref_clk = of_property_read_bool(np, "f2h_ptp_ref_clk");

    Where is "altr,"?

[...]

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
