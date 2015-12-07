From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [PATCH RESEND net-next 2/3] dts: hisi: fixes no syscon error when
 init mdio
Date: Mon, 7 Dec 2015 09:30:56 +0800
Message-ID: <5664E150.4020402@huawei.com>
References: <1449302218-54374-1-git-send-email-yankejian@huawei.com>
 <1449302218-54374-3-git-send-email-yankejian@huawei.com>
 <5330584.WSWh7F8G32@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, wangkefeng.wang@huawei.com, catalin.marinas@arm.com,
 will.deacon@arm.com, linuxarm@huawei.com, haojian.zhuang@linaro.org,
 haifeng.wei@huawei.com, xuwei5@hisilicon.com, galak@codeaurora.org,
 dingtianhong@huawei.com, Yisen.Zhuang@huawei.com, devicetree@vger.kernel.org,
 bintian.wang@huawei.com, pawel.moll@arm.com, ijc+devicetree@hellion.org.uk,
 leo.yan@linaro.org, robh+dt@kernel.org, liguozhu@huawei.com,
 netdev@vger.kernel.org, sboyd@codeaurora.org, linux-kernel@vger.kernel.org,
 wangzhou1@hisilicon.com, long.wanglong@huawei.com, davem@davemloft.net
To: Arnd Bergmann <arnd@arndb.de>, <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <5330584.WSWh7F8G32@wuerfel>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org



On 2015/12/6 6:15, Arnd Bergmann wrote:
> On Saturday 05 December 2015 15:56:57 yankejian wrote:
>>                 #size-cells = <0>;
>>                 compatible = "hisilicon,hns-mdio";
>> -               reg = <0x0 0x803c0000 0x0 0x10000
>> -                      0x0 0x80000000 0x0 0x10000>;
>> +               reg = <0x0 0x803c0000 0x0 0x10000>;
>> +               subctrl_vbase = <&peri_c_subctrl>;
>>  
>>                 soc0_phy0: ethernet-phy@0 {
>>                         reg = <0x0>;
> I don't see the subctrl_vbase property documented in the binding. Please
> modify the binding as well.
>
> Also, please use the normal naming conventions using '-' instead of '_'
> inside of property names.
>
> 	Arnd
>
> .

Hi, Arnd
Thanks for your suggestions. i will fixes it later.
