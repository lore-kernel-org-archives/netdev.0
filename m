From: Scott Wood <scott.wood@nxp.com>
Subject: Re: [v6, 3/5] dt: move guts devicetree doc out of powerpc directory
Date: Fri, 18 Mar 2016 18:16:06 +0000
Message-ID: <HE1PR0401MB1931444381E249E41C45C748918C0@HE1PR0401MB1931.eurprd04.prod.outlook.com>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
 <1457518131-11339-4-git-send-email-yangbo.lu@nxp.com>
 <20160317170640.GB21009@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	"Jochen Friedrich" <jochen@scram.de>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"ulf.hansson@linaro.org" <ulf.hansson@linaro.org>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	"Zhao Qiang" <qiang.zhao@freescale.com>,
	Kumar Gala <galak@codeau
To: Rob Herring <robh@kernel.org>, Yangbo Lu <yangbo.lu@nxp.com>
Return-path: <linux-clk-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/17/2016 12:06 PM, Rob Herring wrote:
> On Wed, Mar 09, 2016 at 06:08:49PM +0800, Yangbo Lu wrote:
>> Move guts devicetree doc to Documentation/devicetree/bindings/soc/fsl/
>> since it's used by not only PowerPC but also ARM. And add a specification
>> for 'little-endian' property.
>>
>> Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
>> ---
>> Changes for v2:
>> 	- None
>> Changes for v3:
>> 	- None
>> Changes for v4:
>> 	- Added this patch
>> Changes for v5:
>> 	- Modified the description for little-endian property
>> Changes for v6:
>> 	- None
>> ---
>>  Documentation/devicetree/bindings/{powerpc => soc}/fsl/guts.txt | 3 +++
>>  1 file changed, 3 insertions(+)
>>  rename Documentation/devicetree/bindings/{powerpc => soc}/fsl/guts.txt (91%)
>>
>> diff --git a/Documentation/devicetree/bindings/powerpc/fsl/guts.txt b/Documentation/devicetree/bindings/soc/fsl/guts.txt
>> similarity index 91%
>> rename from Documentation/devicetree/bindings/powerpc/fsl/guts.txt
>> rename to Documentation/devicetree/bindings/soc/fsl/guts.txt
>> index b71b203..07adca9 100644
>> --- a/Documentation/devicetree/bindings/powerpc/fsl/guts.txt
>> +++ b/Documentation/devicetree/bindings/soc/fsl/guts.txt
>> @@ -25,6 +25,9 @@ Recommended properties:
>>   - fsl,liodn-bits : Indicates the number of defined bits in the LIODN
>>     registers, for those SOCs that have a PAMU device.
>>  
>> + - little-endian : Indicates that the global utilities block is little
>> +   endian. The default is big endian.
> 
> The default is "the native endianness of the system". So absence on an 
> ARM system would be LE.

No.  For this binding, the default is big-endian, because that's what
existed for this device before an endian property was added.

"endianness of the system" is not a well-defined concept.

> This property is valid for any simple-bus device, 

Since when does simple-bus mean anything more than that the nodes
underneath it can be used without bus-specific knowledge?

> so it isn't really required to document per device. You can, but 
> your description had better match the documented behaviour.

Documented where?

In fact, Documentation/devicetree/bindings/common-properties.txt
explicitly says of the endian properties, "If a binding supports these
properties, then the binding should also specify the default behavior if
none of these properties are present."

-Scott

