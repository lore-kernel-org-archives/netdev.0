From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH net-next] bindings: net: stmmac: add missing note about
 LPI interrupt
Date: Mon, 10 Apr 2017 09:43:08 +0200
Message-ID: <379cb3b6-4b4f-b4f0-d5e2-1896c7b677b1@axis.com>
References: <20170407143100.21536-1-niklass@axis.com>
 <c1e78674-64d1-0e51-3ca4-48d8500a3528@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Thierry Reding <treding@nvidia.com>,
        Eric Engestrom <eric@engestrom.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c1e78674-64d1-0e51-3ca4-48d8500a3528@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/07/2017 06:48 PM, Sergei Shtylyov wrote:
> Hello!
> 
> On 04/07/2017 05:30 PM, Niklas Cassel wrote:
> 
>> From: Niklas Cassel <niklas.cassel@axis.com>
>>
>> The hardware has a LPI interrupt.
>> There is already code in the stmmac driver to parse and handle the
>> interrupt. However, this information was missing from the DT binding.
>>
>> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
>> ---
>>  Documentation/devicetree/bindings/net/stmmac.txt | 8 ++++----
>>  1 file changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
>> index f652b0c384ce..8977abc266ac 100644
>> --- a/Documentation/devicetree/bindings/net/stmmac.txt
>> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
>> @@ -8,8 +8,8 @@ Required properties:
>>    that services interrupts for this device
>>  - interrupts: Should contain the STMMAC interrupts
>>  - interrupt-names: Should contain the interrupt names "macirq"
>> -  "eth_wake_irq" if this interrupt is supported in the "interrupts"
>> -  property
>> +  "eth_wake_irq" if this interrupt is supported in the "interrupts property
> 
>    Missed closing quote?

Thanks for pointing it out.
Will send a v2.

> 
>> +  "eth_lpi" if this interrupt is supported in the "interrupts" property
>>  - phy-mode: See ethernet.txt file in the same directory.
>>  - snps,reset-gpio     gpio number for phy reset.
>>  - snps,reset-active-low boolean flag to indicate if phy reset is active low.
> [...]
> 
> MBR, Sergei
> 
