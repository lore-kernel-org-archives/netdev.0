From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 19/22] dt/bindings: add micrel,rmii_ref_clk_sel_25_mhz to
 eth-phy binding
Date: Tue, 11 Nov 2014 17:57:42 +0000
Message-ID: <20141111175741.GF25295@leverpostej>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
 <1415727460-20417-20-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Johan Hovold <johan@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1415727460-20417-20-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 11, 2014 at 05:37:37PM +0000, Johan Hovold wrote:
> Add "micrel,rmii_ref_clk_sel_25_mhz" to Micrel ethernet PHY binding
> documentation.
> 
> Cc: devicetree@vger.kernel.org
> Signed-off-by: Johan Hovold <johan@kernel.org>
> ---
>  Documentation/devicetree/bindings/net/micrel.txt | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
> index a1bab5eaae02..9b08dd6551dd 100644
> --- a/Documentation/devicetree/bindings/net/micrel.txt
> +++ b/Documentation/devicetree/bindings/net/micrel.txt
> @@ -19,6 +19,11 @@ Optional properties:
>  
>                See the respective PHY datasheet for the mode values.
>  
> + - micrel,rmii_ref_clk_sel_25_mhz: rmii_ref_clk_sel bit selects 25 MHz mode
> +
> +		Whether 25 MHz (rather than 50 Mhz) clock mode is selected
> +		when the rmii_ref_clk_sel bit is set.

s/_/-/ in property names please.

That said, I don't follow the meaning. Does this cause the kernel to do
something different, or is is simply that a 25MHz ref clock is wired up?

Surely that should be described via the common clock bindings? Or if
internal through a clock-frequency property?

Mark.
