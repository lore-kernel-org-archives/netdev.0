From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2 2/4] net: phy: dp83867: add support for MAC impedance
 configuration
Date: Wed, 5 Oct 2016 08:58:27 +0530
Message-ID: <20264692-6a13-58c0-c262-f631af8f355e@ti.com>
References: <20161004125607.10569-1-mugunthanvnm@ti.com>
 <20161004125607.10569-3-mugunthanvnm@ti.com> <20161004131032.GL11677@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Tony Lindgren <tony@atomide.com>,
        Russell King <linux@armlinux.org.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Sekhar Nori <nsekhar@ti.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161004131032.GL11677@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 04 October 2016 06:40 PM, Andrew Lunn wrote:
>> +	if (of_property_read_bool(of_node, "ti,max-output-imepdance"))
>> +		dp83867->io_impedance = DP83867_IO_MUX_CFG_IO_IMPEDANCE_MAX;
>> +	else if (of_property_read_bool(of_node, "ti,min-output-imepdance"))
> 
> Did you really test this? Or did you make the same typos in your device
> tree file?
> 

I have tested this and attached the log in cover letter. Since there is
a typo error on both dts and driver it worked as expected. Will send a
v3 ASAP.

Regards
Mugunthan V N
