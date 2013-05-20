From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH v3 6/7] ARM: kirkwood: add gigabit ethernet and mvmdio
 device tree nodes
Date: Mon, 20 May 2013 23:38:00 +0200
Message-ID: <519A97B8.1090503@gmail.com>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org> <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com> <1367854420-8006-7-git-send-email-sebastian.hesselbarth@gmail.com> <20130520212708.GA26519@schnuecks.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@linaro.org>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>,
	Russell King <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Simon Baatz <gmbnomis@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130520212708.GA26519@schnuecks.de>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/20/2013 11:27 PM, Simon Baatz wrote:
> Hi Sebastian,
>
> On Mon, May 06, 2013 at 05:33:39PM +0200, Sebastian Hesselbarth wrote:
>> This patch adds mv643xx_eth and mvmdio device tree nodes for DT enabled
>> Kirkwood boards. Phy nodes are also added with reg property set on a
>> per-board basis.
> ...
>> diff --git a/arch/arm/boot/dts/kirkwood.dtsi b/arch/arm/boot/dts/kirkwood.dtsi
>> index fada7e6..c01a273 100644
>> --- a/arch/arm/boot/dts/kirkwood.dtsi
>> +++ b/arch/arm/boot/dts/kirkwood.dtsi
>> @@ -202,5 +202,57 @@
>>   			clocks =<&gate_clk 4>;
>>   			status = "disabled";
>>   		};
>> +
>> +		mdio: mdio-bus@72004 {
>> +			compatible = "marvell,orion-mdio";
>> +			reg =<0x72004 0x84>;
>> +			interrupts =<11>;
>
> Shouldn't this be 46?

Yes, mdio is using GbE0Err interrupt and that is 14 on IRQ HIGH CAUSE.
I was misled by 11 on IRQ LOW CAUSE.

Sebastian
