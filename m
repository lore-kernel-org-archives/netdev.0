From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH 2/2] Documentation: devictree: Add macb mdio bindings
Date: Sat, 3 Dec 2016 14:40:38 -0800
Message-ID: <bfbc84ce-4975-3213-3b46-8c394c717ea9@gmail.com>
References: <1480326567-6132-1-git-send-email-harinik@xilinx.com>
 <20161203213553.f3agwvaseufglnq6@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: nicolas.ferre@atmel.com, davem@davemloft.net, pawel.moll@arm.com,
        mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
        galak@codeaurora.org, boris.brezillon@free-electrons.com,
        alexandre.belloni@free-electrons.com, harinikatakamlinux@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org, harinik@xilinx.com, michals@xilinx.com
To: Rob Herring <robh@kernel.org>,
        Harini Katakam <harini.katakam@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161203213553.f3agwvaseufglnq6@rob-hp-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 12/03/16 à 13:35, Rob Herring a écrit :
> On Mon, Nov 28, 2016 at 03:19:27PM +0530, Harini Katakam wrote:
>> Add documentations for macb mdio driver.
> 
> Bindings document h/w, not drivers.
> 
>>
>> Signed-off-by: Harini Katakam <harinik@xilinx.com>
>> ---
>>  .../devicetree/bindings/net/macb-mdio.txt          | 31 ++++++++++++++++++++++
>>  1 file changed, 31 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/macb-mdio.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/macb-mdio.txt b/Documentation/devicetree/bindings/net/macb-mdio.txt
>> new file mode 100644
>> index 0000000..014cedf
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/macb-mdio.txt
>> @@ -0,0 +1,31 @@
>> +* Cadence MACB MDIO controller
>> +
>> +Required properties:
>> +- compatible: Should be "cdns,macb-mdio"
> 
> Only one version ever? This needs more specific compatible strings.
> 
>> +- reg: Address and length of the register set of MAC to be used
>> +- clock-names: Tuple listing input clock names.
>> +	Required elements: 'pclk', 'hclk'
>> +	Optional elements: 'tx_clk'
>> +- clocks: Phandles to input clocks.

You are also missing mandatory properties:

#address-cells = <1> and #size-cells = <0>

Where is patch 1? Can you make sure you have the same recipient list for
both patches in this series so we can review both the binding and driver?

Thanks!
-- 
Florian
