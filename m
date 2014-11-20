From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 08/10] dt/bindings: add clock-select function property to
 micrel phy binding
Date: Thu, 20 Nov 2014 10:08:40 +0100
Message-ID: <20141120090840.GI30369@pengutronix.de>
References: <1416398363-32306-1-git-send-email-johan@kernel.org>
 <1416398363-32306-9-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bruno Thomsen <bth@kamstrup.dk>,
	Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org
To: Johan Hovold <johan@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416398363-32306-9-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2014 at 12:59:21PM +0100, Johan Hovold wrote:
> Add "micrel,rmii-reference-clock-select-25-mhz" to Micrel ethernet PHY
> binding documentation.
> 
> This property is needed to properly describe some revisions of Micrel
> PHYs which has the function of this configuration bit inverted so that
> setting it enables 25 MHz rather than 50 MHz clock mode.
> 
> Note that a clock reference ("rmii-ref") is still needed to actually
> select either mode.
> 
> Cc: devicetree@vger.kernel.org
> Signed-off-by: Johan Hovold <johan@kernel.org>
> ---
>  Documentation/devicetree/bindings/net/micrel.txt | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
> index 20a6cac7abc6..87496a8c64ab 100644
> --- a/Documentation/devicetree/bindings/net/micrel.txt
> +++ b/Documentation/devicetree/bindings/net/micrel.txt
> @@ -19,6 +19,17 @@ Optional properties:
>  
>  	See the respective PHY datasheet for the mode values.
>  
> + - micrel,rmii-reference-clock-select-25-mhz: RMII Reference Clock Select
> +						bit selects 25 MHz mode
> +
> +	Setting the RMII Reference Clock Select bit enables 25 MHz rather
> +	than 50 MHz clock mode.
> +
> +	Note that this option in only needed for certain PHY revisions with a
> +	non-standard, inverted function of this configuration bit.
> +	Specifically, a clock reference ("rmii-ref" below) is always needed to
> +	actually select a mode.

Nice, that should be clear.

Acked-by: Sascha Hauer <s.hauer@pengutronix.de>

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
