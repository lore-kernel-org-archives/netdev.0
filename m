From: Frank Rowand <frowand.list@gmail.com>
Subject: Re: [PATCH] of: update ePAPR references to point to Devicetree
 Specification
Date: Mon, 19 Jun 2017 03:23:41 -0700
Message-ID: <5947A62D.6050504@gmail.com>
References: <1497408544-7383-1-git-send-email-frowand.list@gmail.com>
 <20170618140531.jvmnttawom4ns55b@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Mark Rutland <mark.rutland@arm.com>,
        =?UTF-8?Q?Horia_Geant=c4=83?= <horia.geanta@nxp.com>,
        Dan Douglass <dan.douglass@nxp.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Marc Zyngier <marc.zyngier@arm.com>,
        Scott Wood <oss@buserror.net>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Jonathan Corbet <corbet@lwn.net>, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170618140531.jvmnttawom4ns55b@rob-hp-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/18/17 07:05, Rob Herring wrote:
> On Tue, Jun 13, 2017 at 07:49:04PM -0700, frowand.list@gmail.com wrote:
>> From: Frank Rowand <frank.rowand@sony.com>
>>
>> The Devicetree Specification has superseded the ePAPR as the
>> base specification for bindings.  Update files in Documentation
>> to reference the new document.
>>
>> Some files are not updated because there is no hypervisor chapter
>> in the Devicetree Specification:
>>    Documentation/devicetree/bindings/powerpc/fsl/msi-pic.txt
>>    Documenation/virtual/kvm/api.txt
>>    Documenation/virtual/kvm/ppc-pv.txt
>>
>> Signed-off-by: Frank Rowand <frank.rowand@sony.com>
>> ---
>>  Documentation/devicetree/bindings/arm/cci.txt               | 12 ++++++------
>>  Documentation/devicetree/bindings/arm/cpus.txt              | 13 +++++++------
>>  Documentation/devicetree/bindings/arm/idle-states.txt       |  4 ++--
>>  Documentation/devicetree/bindings/arm/l2c2x0.txt            |  4 ++--
>>  Documentation/devicetree/bindings/arm/topology.txt          |  4 ++--
>>  Documentation/devicetree/bindings/bus/simple-pm-bus.txt     |  2 +-
>>  Documentation/devicetree/bindings/chosen.txt                |  3 ++-
>>  Documentation/devicetree/bindings/common-properties.txt     |  2 +-
>>  Documentation/devicetree/bindings/crypto/fsl-sec4.txt       |  4 ++--
>>  Documentation/devicetree/bindings/crypto/fsl-sec6.txt       |  4 ++--
>>  .../devicetree/bindings/interrupt-controller/open-pic.txt   |  5 ++---
>>  Documentation/devicetree/bindings/net/ethernet.txt          |  9 ++++++---
>>  Documentation/devicetree/bindings/powerpc/fsl/cpus.txt      |  6 +++---
>>  Documentation/devicetree/bindings/powerpc/fsl/l2cache.txt   |  2 +-
>>  Documentation/devicetree/bindings/powerpc/fsl/srio-rmu.txt  |  4 ++--
>>  Documentation/devicetree/bindings/powerpc/fsl/srio.txt      |  3 ++-
>>  Documentation/devicetree/booting-without-of.txt             |  2 +-
>>  Documentation/devicetree/usage-model.txt                    |  2 +-
>>  Documentation/xtensa/mmu.txt                                |  6 +++---
>>  19 files changed, 48 insertions(+), 43 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/arm/cci.txt b/Documentation/devicetree/bindings/arm/cci.txt
>> index 0f2153e8fa7e..cc7621b204f4 100644
>> --- a/Documentation/devicetree/bindings/arm/cci.txt
>> +++ b/Documentation/devicetree/bindings/arm/cci.txt
>> @@ -11,9 +11,9 @@ clusters, through memory mapped interface, with a global control register
>>  space and multiple sets of interface control registers, one per slave
>>  interface.
>>  
>> -Bindings for the CCI node follow the ePAPR standard, available from:
>> +Bindings for the CCI node follow the Devicetree Specification, available from:
>>  
>> -www.power.org/documentation/epapr-version-1-1/
>> +https://www.devicetree.org/specifications/
> 
> Actually, I find this meaningless other than in the sense that *every* 
> binding follows the spec. This looks like cut-n-paste from the ARM cpus 
> binding which did follow the spec for cpus to some extent.

Good point.  I can remove the reference to the ePAPR from this file.


>>  
>>  with the addition of the bindings described in this document which are
>>  specific to ARM.
>> @@ -50,10 +50,10 @@ specific to ARM.
>>  			    as a tuple of cells, containing child address,
>>  			    parent address and the size of the region in the
>>  			    child address space.
>> -		Definition: A standard property. Follow rules in the ePAPR for
>> -			    hierarchical bus addressing. CCI interfaces
>> -			    addresses refer to the parent node addressing
>> -			    scheme to declare their register bases.
>> +		Definition: A standard property. Follow rules in the Devicetree
>> +			    Specification for hierarchical bus addressing. CCI
>> +			    interfaces addresses refer to the parent node
>> +			    addressing scheme to declare their register bases.
>>  
>>  	CCI interconnect node can define the following child nodes:
>>  
>> diff --git a/Documentation/devicetree/bindings/arm/cpus.txt b/Documentation/devicetree/bindings/arm/cpus.txt
>> index 1030f5f50207..283c520a2224 100644
>> --- a/Documentation/devicetree/bindings/arm/cpus.txt
>> +++ b/Documentation/devicetree/bindings/arm/cpus.txt
>> @@ -6,9 +6,9 @@ The device tree allows to describe the layout of CPUs in a system through
>>  the "cpus" node, which in turn contains a number of subnodes (ie "cpu")
>>  defining properties for every cpu.
>>  
>> -Bindings for CPU nodes follow the ePAPR v1.1 standard, available from:
>> +Bindings for CPU nodes follow the Devicetree Specification, available from:
>>  
>> -https://www.power.org/documentation/epapr-version-1-1/
>> +https://www.devicetree.org/specifications/
>>  
>>  with updates for 32-bit and 64-bit ARM systems provided in this document.
>>  
>> @@ -16,8 +16,8 @@ with updates for 32-bit and 64-bit ARM systems provided in this document.
>>  Convention used in this document
>>  ================================
>>  
>> -This document follows the conventions described in the ePAPR v1.1, with
>> -the addition:
>> +This document follows the conventions described in the Devicetree
>> +Specification, with the addition:
>>  
>>  - square brackets define bitfields, eg reg[7:0] value of the bitfield in
>>    the reg property contained in bits 7 down to 0
>> @@ -26,8 +26,9 @@ the addition:
>>  cpus and cpu node bindings definition
>>  =====================================
>>  
>> -The ARM architecture, in accordance with the ePAPR, requires the cpus and cpu
>> -nodes to be present and contain the properties described below.
>> +The ARM architecture, in accordance with the Devicetree Specification,
>> +requires the cpus and cpu nodes to be present and contain the properties
>> +described below.
>>  
>>  - cpus node
>>  
>> diff --git a/Documentation/devicetree/bindings/arm/idle-states.txt b/Documentation/devicetree/bindings/arm/idle-states.txt
>> index b8e41c148a3c..7a591333f2b1 100644
>> --- a/Documentation/devicetree/bindings/arm/idle-states.txt
>> +++ b/Documentation/devicetree/bindings/arm/idle-states.txt
>> @@ -695,5 +695,5 @@ cpus {
>>  [4] ARM Architecture Reference Manuals
>>      http://infocenter.arm.com/help/index.jsp
>>  
>> -[5] ePAPR standard
>> -    https://www.power.org/documentation/epapr-version-1-1/
>> +[5] Devicetree Specification
>> +    https://www.devicetree.org/specifications/
>> diff --git a/Documentation/devicetree/bindings/arm/l2c2x0.txt b/Documentation/devicetree/bindings/arm/l2c2x0.txt
>> index d9650c1788f4..fbe6cb21f4cf 100644
>> --- a/Documentation/devicetree/bindings/arm/l2c2x0.txt
>> +++ b/Documentation/devicetree/bindings/arm/l2c2x0.txt
>> @@ -4,8 +4,8 @@ ARM cores often have a separate L2C210/L2C220/L2C310 (also known as PL210/PL220/
>>  PL310 and variants) based level 2 cache controller. All these various implementations
>>  of the L2 cache controller have compatible programming models (Note 1).
>>  Some of the properties that are just prefixed "cache-*" are taken from section
>> -3.7.3 of the ePAPR v1.1 specification which can be found at:
>> -https://www.power.org/wp-content/uploads/2012/06/Power_ePAPR_APPROVED_v1.1.pdf
>> +3.7.3 of the Devicetree Specification which can be found at:
>> +https://www.devicetree.org/specifications/
>>  
>>  The ARM L2 cache representation in the device tree should be done as follows:
>>  
>> diff --git a/Documentation/devicetree/bindings/arm/topology.txt b/Documentation/devicetree/bindings/arm/topology.txt
>> index 1061faf5f602..de9eb0486630 100644
>> --- a/Documentation/devicetree/bindings/arm/topology.txt
>> +++ b/Documentation/devicetree/bindings/arm/topology.txt
>> @@ -29,9 +29,9 @@ corresponding to the system hierarchy; syntactically they are defined as device
>>  tree nodes.
>>  
>>  The remainder of this document provides the topology bindings for ARM, based
>> -on the ePAPR standard, available from:
>> +on the Devicetree Specification, available from:
>>  
>> -http://www.power.org/documentation/epapr-version-1-1/
>> +https://www.devicetree.org/specifications/
>>  
>>  If not stated otherwise, whenever a reference to a cpu node phandle is made its
>>  value must point to a cpu node compliant with the cpu node bindings as
>> diff --git a/Documentation/devicetree/bindings/bus/simple-pm-bus.txt b/Documentation/devicetree/bindings/bus/simple-pm-bus.txt
>> index d032237512c2..6f15037131ed 100644
>> --- a/Documentation/devicetree/bindings/bus/simple-pm-bus.txt
>> +++ b/Documentation/devicetree/bindings/bus/simple-pm-bus.txt
>> @@ -10,7 +10,7 @@ enabled for child devices connected to the bus (either on-SoC or externally)
>>  to function.
>>  
>>  While "simple-pm-bus" follows the "simple-bus" set of properties, as specified
>> -in ePAPR, it is not an extension of "simple-bus".
>> +in the Devicetree Specification, it is not an extension of "simple-bus".
>>  
>>  
>>  Required properties:
>> diff --git a/Documentation/devicetree/bindings/chosen.txt b/Documentation/devicetree/bindings/chosen.txt
>> index b5e39af4ddc0..dee3f5d9df26 100644
>> --- a/Documentation/devicetree/bindings/chosen.txt
>> +++ b/Documentation/devicetree/bindings/chosen.txt
>> @@ -10,7 +10,8 @@ stdout-path property
>>  --------------------
>>  
>>  Device trees may specify the device to be used for boot console output
>> -with a stdout-path property under /chosen, as described in ePAPR, e.g.
>> +with a stdout-path property under /chosen, as described in the Devicetree
>> +Specification, e.g.
>>  
>>  / {
>>  	chosen {
>> diff --git a/Documentation/devicetree/bindings/common-properties.txt b/Documentation/devicetree/bindings/common-properties.txt
>> index 3193979b1d05..697714f8d75c 100644
>> --- a/Documentation/devicetree/bindings/common-properties.txt
>> +++ b/Documentation/devicetree/bindings/common-properties.txt
>> @@ -1,6 +1,6 @@
>>  Common properties
>>  
>> -The ePAPR specification does not define any properties related to hardware
>> +The Devicetree Specification does not define any properties related to hardware
>>  byteswapping, but endianness issues show up frequently in porting Linux to
>>  different machine types.  This document attempts to provide a consistent
>>  way of handling byteswapping across drivers.
>> diff --git a/Documentation/devicetree/bindings/crypto/fsl-sec4.txt b/Documentation/devicetree/bindings/crypto/fsl-sec4.txt
>> index 10a425f451fc..7aef0eae58d4 100644
>> --- a/Documentation/devicetree/bindings/crypto/fsl-sec4.txt
>> +++ b/Documentation/devicetree/bindings/crypto/fsl-sec4.txt
>> @@ -118,8 +118,8 @@ PROPERTIES
>>        Definition: A list of clock name strings in the same order as the
>>            clocks property.
>>  
>> -   Note: All other standard properties (see the ePAPR) are allowed
>> -   but are optional.
>> +   Note: All other standard properties (see the Devicetree Specification)
>> +   are allowed but are optional.
>>  
>>  
>>  EXAMPLE
>> diff --git a/Documentation/devicetree/bindings/crypto/fsl-sec6.txt b/Documentation/devicetree/bindings/crypto/fsl-sec6.txt
>> index baf8a3c1b469..73b0eb950bb3 100644
>> --- a/Documentation/devicetree/bindings/crypto/fsl-sec6.txt
>> +++ b/Documentation/devicetree/bindings/crypto/fsl-sec6.txt
>> @@ -55,8 +55,8 @@ PROPERTIES
>>             triplet that includes the child address, parent address, &
>>             length.
>>  
>> -   Note: All other standard properties (see the ePAPR) are allowed
>> -   but are optional.
>> +   Note: All other standard properties (see the Devicetree Specification)
>> +   are allowed but are optional.
>>  
>>  EXAMPLE
>>  	crypto@a0000 {
>> diff --git a/Documentation/devicetree/bindings/interrupt-controller/open-pic.txt b/Documentation/devicetree/bindings/interrupt-controller/open-pic.txt
>> index 909a902dff85..ccbbfdc53c72 100644
>> --- a/Documentation/devicetree/bindings/interrupt-controller/open-pic.txt
>> +++ b/Documentation/devicetree/bindings/interrupt-controller/open-pic.txt
>> @@ -92,7 +92,6 @@ Example 2:
>>  
>>  * References
>>  
>> -[1] Power.org (TM) Standard for Embedded Power Architecture (TM) Platform
>> -    Requirements (ePAPR), Version 1.0, July 2008.
>> -    (http://www.power.org/resources/downloads/Power_ePAPR_APPROVED_v1.0.pdf)
>> +[1] Devicetree Specification
>> +    (https://www.devicetree.org/specifications/)
>>  
>> diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
>> index 3a6916909d90..08dd263beeb9 100644
>> --- a/Documentation/devicetree/bindings/net/ethernet.txt
>> +++ b/Documentation/devicetree/bindings/net/ethernet.txt
>> @@ -8,7 +8,8 @@ The following properties are common to the Ethernet controllers:
>>    property;
>>  - max-speed: number, specifies maximum speed in Mbit/s supported by the device;
>>  - max-frame-size: number, maximum transfer unit (IEEE defined MTU), rather than
>> -  the maximum frame size (there's contradiction in ePAPR).
>> +  the maximum frame size (there's contradiction in the Devicetree
>> +  Specification).
>>  - phy-mode: string, operation mode of the PHY interface. This is now a de-facto
>>    standard property; supported values are:
>>    * "mii"
>> @@ -32,9 +33,11 @@ The following properties are common to the Ethernet controllers:
>>    * "2000base-x",
>>    * "2500base-x",
>>    * "rxaui"
>> -- phy-connection-type: the same as "phy-mode" property but described in ePAPR;
>> +- phy-connection-type: the same as "phy-mode" property but described in the
>> +  Devicetree Specification;
>>  - phy-handle: phandle, specifies a reference to a node representing a PHY
>> -  device; this property is described in ePAPR and so preferred;
>> +  device; this property is described in the Devicetree Specification and so
>> +  preferred;
>>  - phy: the same as "phy-handle" property, not recommended for new bindings.
>>  - phy-device: the same as "phy-handle" property, not recommended for new
>>    bindings.
>> diff --git a/Documentation/devicetree/bindings/powerpc/fsl/cpus.txt b/Documentation/devicetree/bindings/powerpc/fsl/cpus.txt
>> index f8cd2397aa04..d63ab1dec16d 100644
>> --- a/Documentation/devicetree/bindings/powerpc/fsl/cpus.txt
>> +++ b/Documentation/devicetree/bindings/powerpc/fsl/cpus.txt
>> @@ -3,10 +3,10 @@ Power Architecture CPU Binding
>>  Copyright 2013 Freescale Semiconductor Inc.
>>  
>>  Power Architecture CPUs in Freescale SOCs are represented in device trees as
>> -per the definition in ePAPR.
>> +per the definition in the Devicetree Specification.
> 
> Are we sure we didn't remove any PPC specifics that apply here?

I don't see any.

Table 3.7.1 "General Properties of CPU nodes" was slightly
re-ordered, but the same properties are listed in both documents.

I don't think that the boot requirements removal impacts this
file.

Am I missing something?


>>  
>> -In addition to the ePAPR definitions, the properties defined below may be
>> -present on CPU nodes.
>> +In addition to the the Devicetree Specification definitions, the properties
>> +defined below may be present on CPU nodes.
>>  
>>  PROPERTIES
>>  
>> diff --git a/Documentation/devicetree/bindings/powerpc/fsl/l2cache.txt b/Documentation/devicetree/bindings/powerpc/fsl/l2cache.txt
>> index dc9bb3182525..8a70696395a7 100644
>> --- a/Documentation/devicetree/bindings/powerpc/fsl/l2cache.txt
>> +++ b/Documentation/devicetree/bindings/powerpc/fsl/l2cache.txt
>> @@ -1,7 +1,7 @@
>>  Freescale L2 Cache Controller
>>  
>>  L2 cache is present in Freescale's QorIQ and QorIQ Qonverge platforms.
>> -The cache bindings explained below are ePAPR compliant
>> +The cache bindings explained below are Devicetree Specification compliant
> 
> ditto

No changes to Table 3.8 Multi-level and Shared Caches between the
documents.

-Frank

> 
>>  
>>  Required Properties:
>>  
>> diff --git a/Documentation/devicetree/bindings/powerpc/fsl/srio-rmu.txt b/Documentation/devicetree/bindings/powerpc/fsl/srio-rmu.txt
>> index b9a8a2bcfae7..0496ada4bba4 100644
>> --- a/Documentation/devicetree/bindings/powerpc/fsl/srio-rmu.txt
>> +++ b/Documentation/devicetree/bindings/powerpc/fsl/srio-rmu.txt
>> @@ -124,8 +124,8 @@ Port-Write Unit:
>>  		A single IRQ that handles port-write conditions is
>>  		specified by this property.  (Typically shared with error).
>>  
>> -   Note: All other standard properties (see the ePAPR) are allowed
>> -   but are optional.
>> +   Note: All other standard properties (see the Devicetree Specification)
>> +   are allowed but are optional.
>>  
>>  Example:
>>  	rmu: rmu@d3000 {
>> diff --git a/Documentation/devicetree/bindings/powerpc/fsl/srio.txt b/Documentation/devicetree/bindings/powerpc/fsl/srio.txt
>> index 07abf0f2f440..86ee6ea73754 100644
>> --- a/Documentation/devicetree/bindings/powerpc/fsl/srio.txt
>> +++ b/Documentation/devicetree/bindings/powerpc/fsl/srio.txt
>> @@ -72,7 +72,8 @@ the following properties:
>>  		represents the LIODN associated with maintenance transactions
>>  		for the port.
>>  
>> -Note: All other standard properties (see ePAPR) are allowed but are optional.
>> +Note: All other standard properties (see the Devicetree Specification)
>> +are allowed but are optional.
>>  
>>  Example:
>>  
>> diff --git a/Documentation/devicetree/booting-without-of.txt b/Documentation/devicetree/booting-without-of.txt
>> index 280d283304bb..fb740445199f 100644
>> --- a/Documentation/devicetree/booting-without-of.txt
>> +++ b/Documentation/devicetree/booting-without-of.txt
>> @@ -1413,7 +1413,7 @@ Optional property:
>>  	from DMA operations originating from the bus. It provides a means of
>>  	defining a mapping or translation between the physical address space of
>>  	the bus and the physical address space of the parent of the bus.
>> -	(for more information see ePAPR specification)
>> +	(for more information see the Devicetree Specification)
>>  
>>  * DMA Bus child
>>  Optional property:
>> diff --git a/Documentation/devicetree/usage-model.txt b/Documentation/devicetree/usage-model.txt
>> index 2b6b3d3f0388..33a8aaac02a8 100644
>> --- a/Documentation/devicetree/usage-model.txt
>> +++ b/Documentation/devicetree/usage-model.txt
>> @@ -387,7 +387,7 @@ static void __init harmony_init_machine(void)
>>  	of_platform_populate(NULL, of_default_bus_match_table, NULL, NULL);
>>  }
>>  
>> -"simple-bus" is defined in the ePAPR 1.0 specification as a property
>> +"simple-bus" is defined in the Devicetree Specification as a property
>>  meaning a simple memory mapped bus, so the of_platform_populate() code
>>  could be written to just assume simple-bus compatible nodes will
>>  always be traversed.  However, we pass it in as an argument so that
>> diff --git a/Documentation/xtensa/mmu.txt b/Documentation/xtensa/mmu.txt
>> index 222a2c6748e6..5de8715d5bec 100644
>> --- a/Documentation/xtensa/mmu.txt
>> +++ b/Documentation/xtensa/mmu.txt
>> @@ -41,9 +41,9 @@ The scheme below assumes that the kernel is loaded below 0x40000000.
>>   00..1F -> 00  -> 00  -> 00
>>  
>>  The default location of IO peripherals is above 0xf0000000. This may be changed
>> -using a "ranges" property in a device tree simple-bus node. See ePAPR 1.1, §6.5
>> -for details on the syntax and semantic of simple-bus nodes. The following
>> -limitations apply:
>> +using a "ranges" property in a device tree simple-bus node. See the Devicetree
>> +Specification, section 4.5 for details on the syntax and semantics of
>> +simple-bus nodes. The following limitations apply:
>>  
>>  1. Only top level simple-bus nodes are considered
>>  
>> -- 
>> Frank Rowand <frank.rowand@sony.com>
>>
> 
