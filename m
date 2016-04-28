From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] of: of_mdio: Check if MDIO bus controller is
 available
Date: Thu, 28 Apr 2016 16:12:18 -0700
Message-ID: <572298D2.3060809@gmail.com>
References: <1461880510-27132-1-git-send-email-f.fainelli@gmail.com>
 <20160428221211.GE12753@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	nathan.sullivan@ni.com, nicolas.ferre@atmel.com,
	Rob Herring <robh+dt@kernel.org>,
	Frank Rowand <frowand.list@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	"open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE"
	<devicetree@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160428221211.GE12753@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/04/16 15:12, Andrew Lunn wrote:
> On Thu, Apr 28, 2016 at 02:55:10PM -0700, Florian Fainelli wrote:
>> Add a check whether the 'struct device_node' pointer passed to
>> of_mdiobus_register() is an available (aka enabled) node in the Device
>> Tree.
>>
>> Rationale for doing this are cases where an Ethernet MAC provides a MDIO
>> bus controller and node, and an additional Ethernet MAC might be
>> connecting its PHY/switches to that first MDIO bus controller, while
>> still embedding one internally which is therefore marked as "disabled".
>>
>> Instead of sprinkling checks like these in callers of
>> of_mdiobus_register(), do this in a central location.
> 
> I think this discussion has shown there is no documented best
> practices for MDIO bus drivers and how PHYs nodes are placed within
> device tree. Maybe you could document the generic MDIO binding, both
> as integrated into a MAC device node, and as a separate device?

Fair enough, I will submit something after re-spining this patch to use
-ENODEV, which I agree is a better return code. Did you want me to
remove that blurb from the commit message?
-- 
Florian
