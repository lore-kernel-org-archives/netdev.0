From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: Re: [PATCH v3 2/4] dt-bindings: can: fixed-transceiver: Add new CAN
 fixed transceiver bindings
Date: Thu, 3 Aug 2017 04:48:14 -0500
Message-ID: <3848fab8-ebcf-5b29-7e4e-eb1a2b03803d@ti.com>
References: <20170803005150.9286-1-fcooper@ti.com>
 <20170803005150.9286-3-fcooper@ti.com>
 <f92513b6-6b2b-e08d-72e2-dedd7e0190f4@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <dev.kurt@vandijck-laurijssen.be>, <andrew@lunn.ch>,
        <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f92513b6-6b2b-e08d-72e2-dedd7e0190f4@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/03/2017 04:18 AM, Sergei Shtylyov wrote:
> Hello!
> 
> On 8/3/2017 3:51 AM, Franklin S Cooper Jr wrote:
> 
>> Add documentation to describe usage of the new fixed transceiver binding.
>> This new binding is applicable for any CAN device therefore it exists as
>> its own document.
>>
>> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
>> ---
>>   .../bindings/net/can/fixed-transceiver.txt         | 24
>> ++++++++++++++++++++++
>>   1 file changed, 24 insertions(+)
>>   create mode 100644
>> Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
>>
>> diff --git
>> a/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
>> b/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
>> new file mode 100644
>> index 0000000..2f58838b
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
>> @@ -0,0 +1,24 @@
>> +Fixed transceiver Device Tree binding
>> +------------------------------
>> +
>> +CAN transceiver typically limits the max speed in standard CAN and
>> CAN FD
>> +modes. Typically these limitations are static and the transceivers
>> themselves
>> +provide no way to detect this limitation at runtime. For this situation,
>> +the "fixed-transceiver" node can be used.
>> +
>> +Required Properties:
>> + max-bitrate:    a positive non 0 value that determines the max
>> +        speed that CAN/CAN-FD can run. Any other value
>> +        will be ignored.
>> +
>> +Examples:
>> +
>> +Based on Texas Instrument's TCAN1042HGV CAN Transceiver
>> +
>> +m_can0 {
>> +    ....
>> +    fixed-transceiver@0 {
> 
>    The <unit-address> (after @) must only be specified if there's "reg"

Sorry. Fixed this in my v2 and some how it came back. Will fix.

> prop in the device node. Also, please name the node "can-transceiver@"
> to be more in line with the DT spec. which requires generic node names.

Its possible for future can transceivers drivers to be created. So I
thought including fixed was important to indicate that this is a "dumb"
transceiver similar to "fixed-link". So would "fixed-can-transceiver" be
ok or do you want to go with can-transceiver?
> 
> [...]

> 
> MBR, Sergei
