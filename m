From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/2] can: sja1000: add documentation for Technologic
 Systems version
Date: Sat, 19 Dec 2015 21:37:42 -0600
Message-ID: <20151220033742.GA9883@rob-hp-laptop>
References: <1450469845-12900-1-git-send-email-damien.riegel@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, devicetree@vger.kernel.org,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	kernel@savoirfairelinux.com
To: Damien Riegel <damien.riegel@savoirfairelinux.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1450469845-12900-1-git-send-email-damien.riegel@savoirfairelinux.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 18, 2015 at 03:17:24PM -0500, Damien Riegel wrote:
> This commit adds documentation for the Technologic Systems version of
> SJA1000. The difference with the NXP version is in the way the registers
> are accessed.
> 
> Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
> ---
>  Documentation/devicetree/bindings/net/can/sja1000.txt | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/can/sja1000.txt b/Documentation/devicetree/bindings/net/can/sja1000.txt
> index b4a6d53..7a158d5 100644
> --- a/Documentation/devicetree/bindings/net/can/sja1000.txt
> +++ b/Documentation/devicetree/bindings/net/can/sja1000.txt
> @@ -2,7 +2,7 @@ Memory mapped SJA1000 CAN controller from NXP (formerly Philips)
>  
>  Required properties:
>  
> -- compatible : should be "nxp,sja1000".
> +- compatible : should be one of "nxp,sja1000", "technologic,sja1000".
>  
>  - reg : should specify the chip select, address offset and size required
>  	to map the registers of the SJA1000. The size is usually 0x80.
> @@ -14,6 +14,7 @@ Optional properties:
>  
>  - reg-io-width : Specify the size (in bytes) of the IO accesses that
>  	should be performed on the device.  Valid value is 1, 2 or 4.
> +	Must be set to 2 for technologic version.
>  	Default to 1 (8 bits).

Really, this should default to 2 for technologic version and not be 
required.

Rob
