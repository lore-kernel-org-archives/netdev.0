From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v5] can: xilinx CAN controller support.
Date: Wed, 05 Mar 2014 07:58:49 +0100
Message-ID: <5316CB29.7040200@hartkopp.net>
References: <5254bfec-c6fd-4681-a34d-706d51e60fbb@VA3EHSMHS004.ehs.local> <1b9f22ac-4dde-4ecc-885a-3d8081157081@AM1EHSMHS012.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?U8O2cmVuIEJyaW5rbWFubg==?= <soren.brinkmann@xilinx.com>,
	wg@grandegger.com, mkl@pengutronix.de, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1b9f22ac-4dde-4ecc-885a-3d8081157081@AM1EHSMHS012.ehs.local>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05.03.2014 00:51, S=C3=B6ren Brinkmann wrote:
> Hi Kedar,
>=20
> On Tue, 2014-03-04 at 06:50PM +0530, Kedareswara rao Appana wrote:
>> This patch adds xilinx CAN controller support.
>> This driver supports both ZYNQ CANPS and Soft IP
>> AXI CAN controller.
>>
> [...]
>> diff --git a/Documentation/devicetree/bindings/net/can/xilinx_can.tx=
t b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
>> new file mode 100644
>> index 0000000..0e57103
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
>> @@ -0,0 +1,45 @@
>> +Xilinx Axi CAN/Zynq CANPS controller Device Tree Bindings
>> +---------------------------------------------------------
>> +
>> +Required properties:
>> +- compatible		: Should be "xlnx,zynq-can-1.00.a" for Zynq CAN
>> +			  controllers and "xlnx,axi-can-1.00.a" for Axi CAN
>> +			  controllers.
>> +- reg			: Physical base address and size of the Axi CAN/Zynq
>> +			  CANPS registers map.
>> +- interrupts		: Property with a value describing the interrupt
>> +			  number.
>> +- interrupt-parent	: Must be core interrupt controller
>> +- clock-names		: List of input clock names - "ref_clk", "aper_clk"
>=20
> Let's reconsider these names. These are rather Zynq specific names. D=
oes
> the IP documentation use these as well? The names should match the
> naming used for the IP, rather than the SOC. Is this the correct data=
 sheet:
> http://www.xilinx.com/support/documentation/ip_documentation/axi_can/=
v1_03_a/ds791_axi_can.pdf
> ? According to that the names should rather be 's_axi_aclk' and
> 'can_clk', IMHO.
>=20
> 	S=C3=B6ren
>=20

And when renaming stuff anyway:

+
+#define DRIVER_NAME	"XILINX_CAN"
+

should be changed to

+
+#define DRIVER_NAME	"xilinx_can"
+

Regards,
Oliver

