From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [PATCH RESEND net-next 3/3] arm64: hip05-d02: Document devicetree
 bindings for Hisilicon D02 Board
Date: Mon, 7 Dec 2015 09:29:59 +0800
Message-ID: <5664E117.6060105@huawei.com>
References: <1449302218-54374-1-git-send-email-yankejian@huawei.com>
 <1449302218-54374-4-git-send-email-yankejian@huawei.com>
 <2441219.omPQqZs8vd@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
	<galak@codeaurora.org>, <xuwei5@hisilicon.com>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<wangkefeng.wang@huawei.com>, <dingtianhong@huawei.com>,
	<liguozhu@huawei.com>, <Yisen.Zhuang@huawei.com>,
	<sboyd@codeaurora.org>, <haojian.zhuang@linaro.org>,
	<wangzhou1@hisilicon.com>, <bintian.wang@huawei.com>,
	<long.wanglong@huawei.com>, <leo.yan@linaro.org>,
	<haifeng.wei@huawei.com>, <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2441219.omPQqZs8vd@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/12/6 6:13, Arnd Bergmann wrote:
> On Saturday 05 December 2015 15:56:58 yankejian wrote:
>> +Required properties:
>> +- compatible : "hisilicon,peri-c-subctrl", "syscon";
>> +- reg : Register address and size
>> +
>> +The HiP05 PERISUB system controller is shared by peripheral controllers in
>> +HiP05 Soc to implement some basic configurations. the peripheral
>> + controllers include mdio, ddr, iic, uart, timer and so on.
>> +
>> +Example:
>> +       /* for HiP05 PCIe-SAS system */
>> +       pcie_sas: system_controller@0xb0000000 {
>> +               compatible = "hisilicon,pcie-sas-subctrl", "syscon";
>> +               reg = <0xb0000000 0x10000>;
>> +       };
>>
> The compatible string in the example does not match the required properties.
>
> 	Arnd
>
> .
Hi, Arnd
Thanks for your suggestions. i will fixes it later.
