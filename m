From: Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] Documentation: devicetree: change the mediatek
 ethernet compatible string
Date: Wed, 25 Jan 2017 11:43:16 +0100
Message-ID: <95bbd455-fb78-b41c-ef09-6d35671e68c3@gmail.com>
References: <1485332455-34743-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1485332455-34743-1-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 01/25/2017 09:20 AM, John Crispin wrote:
> When the binding was defined, I was not aware that mt2701 was an earlier
> version of the SoC. For sake of consistency, the ethernet driver should
> use mt2701 inside the compat string as this is the earliest SoC with the
> ethernet core.
>
> The ethernet driver is currently of no real use until we finish and
> upstream the DSA driver. There are no users of this binding yet. It should
> be safe to fix this now before it is too late and we need to provide
> backward compatibility for the mt7623-eth compat string.
>
> Reported-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
> ---

sounds reasonable to me:
Reviewed-by: Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

>  Documentation/devicetree/bindings/net/mediatek-net.txt |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
> index c010faf..c7194e8 100644
> --- a/Documentation/devicetree/bindings/net/mediatek-net.txt
> +++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
> @@ -7,7 +7,7 @@ have dual GMAC each represented by a child node..
>  * Ethernet controller node
>
>  Required properties:
> -- compatible: Should be "mediatek,mt7623-eth"
> +- compatible: Should be "mediatek,mt2701-eth"
>  - reg: Address and length of the register set for the device
>  - interrupts: Should contain the three frame engines interrupts in numeric
>  	order. These are fe_int0, fe_int1 and fe_int2.
>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
