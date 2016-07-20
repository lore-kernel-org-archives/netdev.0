From: Nishanth Menon <nm@ti.com>
Subject: Re: [net-next PATCH 1/3] net: phy: dp83867: Add documentation for
 optional impedance control
Date: Wed, 20 Jul 2016 10:33:39 -0500
Message-ID: <578F99D3.9090601@ti.com>
References: <20160720145614.13132-1-mugunthanvnm@ti.com>
 <20160720145614.13132-2-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
	Tony Lindgren <tony@atomide.com>,
	Russell King <linux@armlinux.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Sekhar Nori <nsekhar@ti.com>, <devicetree@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>, <netdev@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160720145614.13132-2-mugunthanvnm@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/20/2016 09:56 AM, Mugunthan V N wrote:
> Add documention of ti,impedance-control which can be used to
> correct MAC impedance mismatch using phy extended registers.
>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>   Documentation/devicetree/bindings/net/ti,dp83867.txt | 7 +++++++
>   1 file changed, 7 insertions(+)
>
> diff --git a/Documentation/devicetree/bindings/net/ti,dp83867.txt b/Documentation/devicetree/bindings/net/ti,dp83867.txt
> index 5d21141..531ea3c5 100644
> --- a/Documentation/devicetree/bindings/net/ti,dp83867.txt
> +++ b/Documentation/devicetree/bindings/net/ti,dp83867.txt
> @@ -9,6 +9,13 @@ Required properties:
>   	- ti,fifo-depth - Transmitt FIFO depth- see dt-bindings/net/ti-dp83867.h
>   		for applicable values
>
> +Optional property:
> +	- ti,impedance-control - MAC Interface Impedance control to vary the
> +				 output impedance with an approximate range
> +				 from 35-70 ohms in 32 steps. Value range can
> +				 be 0x0 to 0x1f. Lowest impedance value is
> +				 0x1f and highest impedance being 0x0.
> +

Should'nt you be using the impedance values of 35 to 70 as the valid 
values here? that would be the hardware description, and the values to 
program corresponding to those are 0x00 to 0x1f. Right?

Rob: is'nt that the right way to do it?

>   Default child nodes are standard Ethernet PHY device
>   nodes as described in Documentation/devicetree/bindings/net/phy.txt
>
>


-- 
Regards,
Nishanth Menon
