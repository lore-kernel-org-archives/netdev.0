From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH v5] can: xilinx CAN controller support.
Date: Mon, 10 Mar 2014 16:26:53 +0100
Message-ID: <1964213d-6bd9-49fa-805e-42e1e0630fd5@VA3EHSMHS029.ehs.local>
References: <5254bfec-c6fd-4681-a34d-706d51e60fbb@VA3EHSMHS004.ehs.local> <531DD493.3030306@monstr.eu> <531DD5E7.7090406@pengutronix.de> <3245971.RIuVmbVL0Z@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>, <monstr@monstr.eu>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <michal.simek@xilinx.com>,
	<linux-can@vger.kernel.org>, <robh+dt@kernel.org>,
	Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	<grant.likely@linaro.org>,
	Kedareswara rao Appana <appanad@xilinx.com>,
	<wg@grandegger.com>, Fengguang Wu <fengguang.wu@intel.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3245971.RIuVmbVL0Z@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/10/2014 04:15 PM, Arnd Bergmann wrote:
> On Monday 10 March 2014 16:10:31 Marc Kleine-Budde wrote:
>>>>> +config CAN_XILINXCAN
>>>>> +   tristate "Xilinx CAN"
>>>>> +   depends on ARCH_ZYNQ || MICROBLAZE
>>>>
>>>> Is Zynq multiarch already?
>>>
>>> let me just answer this. Zynq is device with hardcoded dual arm cortex-a9 + some IPs
>>> and programmable logic.
>>> It means if you add Microblaze to PL or another CPU then you get multi architecture setup.
>>
>> Sorry for the confusion, I'm not talking about
>> more-than-one-architecture-in-a-FPGA, but the feature of the ARM-Linux
>> Kernel to run on different ARM architecture. For example, it's possible
>> to start the same kernel on a freescale imx6 and a the new marvel ebu
>> platform. If the Zynq Kernel supports this feature, too, we should not
>> limit to ARCH_ZYNQ, but use ARM instead.
> 
> Zynq has been multiplatform capable from the start. Ideally we'd let
> users build the driver for any architecture and specify the exact
> dependencies, it doesn't even have to be limited to ARM.
> 
> You probably want something like
> 
> 	config CAN_XILINX
> 	tristate "Xilinx CAN"
> 	depends on ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST
> 	depends on COMMON_CLK && HAS_MMIO  # whatever you need for other architectures

Fengguang: Are you use COMPILE_TEST in zero day testing system?

Thanks,
Michal
