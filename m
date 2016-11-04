From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v6 7/7] arm64: dts: NS2: add AMAC ethernet support
Date: Fri, 4 Nov 2016 16:31:40 +0300
Message-ID: <69ecd9b9-d495-9dfa-ad26-4fa622d951a0@cogentembedded.com>
References: <1478236262-3351-1-git-send-email-jon.mason@broadcom.com>
 <1478236262-3351-8-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1478236262-3351-8-git-send-email-jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/4/2016 8:11 AM, Jon Mason wrote:

> Add support for the AMAC ethernet to the Broadcom Northstar2 SoC device
> tree
>
> Signed-off-by: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> ---
>  arch/arm64/boot/dts/broadcom/ns2-svk.dts |  5 +++++
>  arch/arm64/boot/dts/broadcom/ns2.dtsi    | 12 ++++++++++++
>  2 files changed, 17 insertions(+)
>
> diff --git a/arch/arm64/boot/dts/broadcom/ns2-svk.dts b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
> index b09f3bc..c4d5442 100644
> --- a/arch/arm64/boot/dts/broadcom/ns2-svk.dts
> +++ b/arch/arm64/boot/dts/broadcom/ns2-svk.dts
> @@ -56,6 +56,10 @@
>  	};
>  };
>
> +&enet {
> +	status = "ok";

    The spec dictates it should be "okay" (although "ok" is also recognized).

> +};
> +
>  &pci_phy0 {
>  	status = "ok";
>  };
> @@ -174,6 +178,7 @@
>  &mdio_mux_iproc {
>  	mdio@10 {
>  		gphy0: eth-phy@10 {
> +			enet-phy-lane-swap;
>  			reg = <0x10>;
>  		};
>  	};
[...]

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
