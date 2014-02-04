From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net-next 1/2] dts: Add bindings for multicast hash bins
 and perfect filter entries
Date: Tue, 4 Feb 2014 10:58:21 +0100
Message-ID: <52F0B9BD.7070904@st.com>
References: <1391199356-27226-1-git-send-email-vbridgers2013@gmail.com> <1391199356-27226-2-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<dinguyen@altera.com>, <rayagond@vayavyalabs.com>
To: Vince Bridgers <vbridgers2013@gmail.com>,
	<devicetree@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog122.obsmtp.com ([207.126.144.153]:58897 "EHLO
	eu1sys200aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754152AbaBDK0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 05:26:54 -0500
In-Reply-To: <1391199356-27226-2-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Vince

On 1/31/2014 9:15 PM, Vince Bridgers wrote:
> This change adds bindings for the number of multicast hash bins and perfect
> filter entries supported by the Synopsys EMAC. The Synopsys EMAC core is
> configurable at device creation time, and can be configured for a different
> number of multicast hash bins and a different number of perfect filter entries.
> The device does not provide a way to query these parameters, therefore
> parameters are required. The Altera Cyclone V SOC has support for 256
> multicast hash bins and 128 perfect filter entries, and is different than
> what's currently provided in the stmmac driver.
>

thanks a lot for these patches, I have just added some comment for the
patch #2

peppe

> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> ---
>   Documentation/devicetree/bindings/net/stmmac.txt |    6 ++++++
>   1 file changed, 6 insertions(+)
>
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index 9d92d42..dbf7498 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -34,6 +34,10 @@ Optional properties:
>   	reset phandle is given
>   - max-frame-size:	Maximum Transfer Unit (IEEE defined MTU), rather
>   			than the maximum frame size.
> +- snps,multicast-filter-bins:	Number of multicast filter hash bins
> +				supported by this device instance
> +- snps,perfect-filter-entries:	Number of perfect filter entries supported
> +				by this device instance
>
>   Examples:
>
> @@ -46,4 +50,6 @@ Examples:
>   		mac-address = [000000000000]; /* Filled in by U-Boot */
>   		max-frame-size = <3800>;
>   		phy-mode = "gmii";
> +		snps,multicast-filter-bins = <256>;
> +		snps,perfect-filter-entries = <128>;
>   	};
>
