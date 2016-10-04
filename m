From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 2/4] net: phy: dp83867: add support for MAC impedance
 configuration
Date: Tue, 4 Oct 2016 15:10:32 +0200
Message-ID: <20161004131032.GL11677@lunn.ch>
References: <20161004125607.10569-1-mugunthanvnm@ti.com>
 <20161004125607.10569-3-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Tony Lindgren <tony@atomide.com>,
        Russell King <linux@armlinux.org.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Sekhar Nori <nsekhar@ti.com>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161004125607.10569-3-mugunthanvnm@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +	if (of_property_read_bool(of_node, "ti,max-output-imepdance"))
> +		dp83867->io_impedance = DP83867_IO_MUX_CFG_IO_IMPEDANCE_MAX;
> +	else if (of_property_read_bool(of_node, "ti,min-output-imepdance"))

Did you really test this? Or did you make the same typos in your device
tree file?

    Andrew
