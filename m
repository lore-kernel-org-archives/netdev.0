From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCHv3 4/5] arm: mvebu: Add device tree for 98DX3236 SoCs
Date: Mon, 9 Jan 2017 12:44:33 -0600
Message-ID: <20170109184433.h3xcot3ybftk7tz3@rob-hp-laptop>
References: <20170105033641.6212-1-chris.packham@alliedtelesis.co.nz>
 <20170106041517.9589-1-chris.packham@alliedtelesis.co.nz>
 <20170106041517.9589-5-chris.packham@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org,
        Mark Rutland <mark.rutland@arm.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Russell King <linux@armlinux.org.uk>,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Chris Packham <chris.packham@alliedtelesis.co.nz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170106041517.9589-5-chris.packham@alliedtelesis.co.nz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 06, 2017 at 05:15:01PM +1300, Chris Packham wrote:
> The Marvell 98DX3236, 98DX3336, 98DX4521 and variants are switch ASICs
> with integrated CPUs. They are similar to the Armada XP SoCs but have
> different I/O interfaces.
> 
> Signed-off-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
> ---
>     Changes in v2:
>     - Update devicetree binding documentation to reflect that 98DX3336 and
>       984251 are supersets of 98DX3236.
>     - disable crypto block
>     - disable sdio for 98DX3236, enable for 98DX4251
>     Changes in v3:
>     - fix typo 4521 -> 4251
>     - document prestera bindings
>     - rework corediv-clock binding
>     - add label to packet processor node
>     - add new compativle string for DFX server
> 
>  .../devicetree/bindings/arm/marvell/98dx3236.txt   |  23 ++
>  .../devicetree/bindings/net/marvell,prestera.txt   |  50 ++++
>  arch/arm/boot/dts/armada-xp-98dx3236.dtsi          | 254 +++++++++++++++++++++
>  arch/arm/boot/dts/armada-xp-98dx3336.dtsi          |  76 ++++++
>  arch/arm/boot/dts/armada-xp-98dx4251.dtsi          |  90 ++++++++
>  5 files changed, 493 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/arm/marvell/98dx3236.txt
>  create mode 100644 Documentation/devicetree/bindings/net/marvell,prestera.txt
>  create mode 100644 arch/arm/boot/dts/armada-xp-98dx3236.dtsi
>  create mode 100644 arch/arm/boot/dts/armada-xp-98dx3336.dtsi
>  create mode 100644 arch/arm/boot/dts/armada-xp-98dx4251.dtsi

Acked-by: Rob Herring <robh@kernel.org>
