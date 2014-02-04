From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH net-next 1/2] dts: Add bindings for multicast hash bins
 and perfect filter entries
Date: Tue, 4 Feb 2014 11:25:01 -0600
Message-ID: <CAL_JsqKo6=n8NfXt-VtXEip47s6ePhcqSpTbOtk6EHECtER4aQ@mail.gmail.com>
References: <1391199356-27226-1-git-send-email-vbridgers2013@gmail.com>
	<1391199356-27226-2-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Dinh Nguyen <dinguyen@altera.com>,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f170.google.com ([209.85.128.170]:49613 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932101AbaBDRZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 12:25:02 -0500
In-Reply-To: <1391199356-27226-2-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 31, 2014 at 2:15 PM, Vince Bridgers <vbridgers2013@gmail.com> wrote:
> This change adds bindings for the number of multicast hash bins and perfect
> filter entries supported by the Synopsys EMAC. The Synopsys EMAC core is
> configurable at device creation time, and can be configured for a different
> number of multicast hash bins and a different number of perfect filter entries.
> The device does not provide a way to query these parameters, therefore
> parameters are required. The Altera Cyclone V SOC has support for 256
> multicast hash bins and 128 perfect filter entries, and is different than
> what's currently provided in the stmmac driver.
>
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>

Acked-by: Rob Herring <robh@kernel.org>

> ---
>  Documentation/devicetree/bindings/net/stmmac.txt |    6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index 9d92d42..dbf7498 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -34,6 +34,10 @@ Optional properties:
>         reset phandle is given
>  - max-frame-size:      Maximum Transfer Unit (IEEE defined MTU), rather
>                         than the maximum frame size.
> +- snps,multicast-filter-bins:  Number of multicast filter hash bins
> +                               supported by this device instance
> +- snps,perfect-filter-entries: Number of perfect filter entries supported
> +                               by this device instance
>
>  Examples:
>
> @@ -46,4 +50,6 @@ Examples:
>                 mac-address = [000000000000]; /* Filled in by U-Boot */
>                 max-frame-size = <3800>;
>                 phy-mode = "gmii";
> +               snps,multicast-filter-bins = <256>;
> +               snps,perfect-filter-entries = <128>;
>         };
> --
> 1.7.9.5
>
