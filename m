From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] net: rfkill-regulator: Add devicetree support.
Date: Sat, 8 Feb 2014 01:22:25 -0500
Message-ID: <20140208012225.d7a311c7.billfink@mindspring.com>
References: <1391802529-29861-1-git-send-email-marek@goldelico.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net, linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net, grant.likely@linaro.org, neilb@suse.de,
	hns@goldelico.com, devicetree@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Marek Belisko <marek@goldelico.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:35195 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750748AbaBHGYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Feb 2014 01:24:53 -0500
In-Reply-To: <1391802529-29861-1-git-send-email-marek@goldelico.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  7 Feb 2014, Marek Belisko wrote:

> Signed-off-by: NeilBrown <neilb@suse.de>
> Signed-off-by: Marek Belisko <marek@goldelico.com>
> ---
> Based on Neil's patch and extend for documentation and bindings include.
> 
>  .../bindings/net/rfkill/rfkill-relugator.txt       | 28 ++++++++++++++++

                                  ^^^^^^^^^
                                  Typo in file name.

					-Bill



>  include/dt-bindings/net/rfkill-regulator.h         | 23 +++++++++++++
>  net/rfkill/rfkill-regulator.c                      | 38 ++++++++++++++++++++++
>  3 files changed, 89 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
>  create mode 100644 include/dt-bindings/net/rfkill-regulator.h
> 
> diff --git a/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt b/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
> new file mode 100644
> index 0000000..cdb7dd7
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
> @@ -0,0 +1,28 @@
> +Regulator consumer for rfkill devices
> +
> +Required properties:
> +- compatible   : Must be "rfkill-regulator".
> +- label  : Name of rfkill device.
> +- type  : Type of rfkill device.
> +
> +Possible values (defined in include/dt-bindings/net/rfkill-regulator.h):
> +	RFKILL_TYPE_ALL
> +	RFKILL_TYPE_WLAN
> +	RFKILL_TYPE_BLUETOOTH
> +	RFKILL_TYPE_UWB
> +	RFKILL_TYPE_WIMAX
> +	RFKILL_TYPE_WWAN
> +	RFKILL_TYPE_GPS
> +	RFKILL_TYPE_FM
> +	RFKILL_TYPE_NFC
> +
> +- vrfkill-supply - regulator device.
> +
> +Example:
> +	gps-rfkill {
> +		compatible = "rfkill-regulator";
> +		label = "GPS";
> +		type = <RFKILL_TYPE_GPS>;
> +		vrfkill-supply = <&reg>;
> +	};
> +
