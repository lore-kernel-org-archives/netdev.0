From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/7] dt-bindings: Add Cavium Octeon Common Ethernet
 Interface.
Date: Wed, 1 Nov 2017 18:09:17 -0700
Message-ID: <af0de889-a34b-8346-9eeb-171498cc61ca@gmail.com>
References: <20171102003606.19913-1-david.daney@cavium.com>
 <20171102003606.19913-2-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>,
        devicetree@vger.kernel.org, Carlos Munoz <cmunoz@cavium.com>
To: David Daney <david.daney@cavium.com>, linux-mips@linux-mips.org,
        ralf@linux-mips.org, James Hogan <james.hogan@mips.com>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171102003606.19913-2-david.daney@cavium.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/01/2017 05:36 PM, David Daney wrote:
> From: Carlos Munoz <cmunoz@cavium.com>
> 
> Add bindings for Common Ethernet Interface (BGX) block.
> 
> Signed-off-by: Carlos Munoz <cmunoz@cavium.com>
> Signed-off-by: Steven J. Hill <Steven.Hill@cavium.com>
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---
[snip]
> +Properties:
> +
> +- compatible: "cavium,octeon-7360-xcv": Compatibility with cn73xx SOCs.
> +
> +- reg: The index of the interface within the BGX block.
> +
> +- local-mac-address: Mac address for the interface.
> +
> +- phy-handle: phandle to the phy node connected to the interface.
> +
> +- cavium,rx-clk-delay-bypass: Set to <1> to bypass the rx clock delay setting.
> +  Needed by the Micrel PHY.

Is not that implied by an appropriate "phy-mode" property already?
-- 
Florian
