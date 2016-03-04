From: Alexandre Torgue <alexandre.torgue@gmail.com>
Subject: Re: [PATCH v3 2/4] Documentation: Bindings: Add STM32 DWMAC glue
Date: Fri, 4 Mar 2016 10:04:07 +0100
Message-ID: <CAJgp7zz3XEY=z6xT91tpYRo4yzaD6zcd0YrweQeuk81+arFMTg@mail.gmail.com>
References: <1456483912-32090-1-git-send-email-alexandre.torgue@gmail.com>
	<1456483912-32090-3-git-send-email-alexandre.torgue@gmail.com>
	<20160302183309.GA2449@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev <netdev@vger.kernel.org>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160302183309.GA2449@rob-hp-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rob,

2016-03-02 19:33 GMT+01:00 Rob Herring <robh@kernel.org>:
> On Fri, Feb 26, 2016 at 11:51:50AM +0100, Alexandre TORGUE wrote:
>> Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>
>>
>> diff --git a/Documentation/devicetree/bindings/net/stm32-dwmac.txt b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
>> new file mode 100644
>> index 0000000..67fceda
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
>> @@ -0,0 +1,40 @@
>> +STMicroelectronics STM32 / MCU DWMAC glue layer controller
>> +
>> +This file documents platform glue layer for stmmac.
>> +Please see stmmac.txt for the other unchanged properties.
>> +
>> +The device node has following properties.
>> +
>> +Required properties:
>> +- compatible:  Should be "st,stm32-dwmac" to select glue, and
>> +            "snps,dwmac-3.50a" to select IP vesrion.
>> +- clocks: Should contain the GMAC main clock, and tx clock
>> +- compatible:  Should be "st,stm32-dwmac" to select glue and
>> +            "snps,dwmac-3.50a" to select IP version.
>> +- clocks: Should contain the MAC main clock
>> +- clock-names: Should contain the clock names "stmmaceth".
>> +- st,syscon : Should be phandle/offset pair. The phandle to the syscon node which
>> +           encompases the glue register, and the offset of the control register.
>> +
>> +Optional properties:
>> +- clocks: Could contain:
>> +     - the tx clock,
>> +     - the rx clock
>> +- clock-names: Could contain the clock names "tx-clk", "rx-clk"
>
> Either the IP block has 3 clocks or it has 1. If you have a case where 1
> clock feeds all 3 inputs, then list the clock 3 times.

I agree. I will move rx/tx clock to required properties and then send a v4.

Regards.

Alexandre
>
> Rob
