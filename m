From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [PATCH net-next 2/2] net: hns: enet specisies a reference to dsaf
 (config and documents)
Date: Tue, 8 Dec 2015 20:21:05 +0800
Message-ID: <5666CB31.6090109@huawei.com>
References: <1449302356-54658-1-git-send-email-yankejian@huawei.com>
 <1449302356-54658-3-git-send-email-yankejian@huawei.com>
 <20151207141221.GA18040@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <arnd@arndb.de>, <fengguang.wu@intel.com>,
	<pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<salil.mehta@huawei.com>, <Yisen.Zhuang@huawei.com>,
	<liguozhu@huawei.com>, <lisheng011@huawei.com>,
	<huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
	<haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151207141221.GA18040@rob-hp-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/12/7 22:12, Rob Herring wrote:
> On Sat, Dec 05, 2015 at 03:59:16PM +0800, yankejian wrote:
>> when enet specisies a reference to dsaf, the correlative config and
> s/when/When/
ok=EF=BC=8Ci will pay attention to it on patch v3.
thanks.
>> documents needs to update. this patch updates the correlative dtsi f=
ile
> s/this/This/
ok=EF=BC=8Ci will pay attention to it on patch v3.
thanks.
>> and bindings documents .
>                         ^
> extra space
>
> This change breaks compatibility with old dtbs. IIRC, this is all new=
,=20
> so maybe it doesn't matter, but you should be explicit that you are=20
> doing that.
>
ok=EF=BC=8Ci will pay attention to it on patch v3.
thanks.
>> Signed-off-by: yankejian <yankejian@huawei.com>
>> ---
>>  .../devicetree/bindings/net/hisilicon-hns-dsaf.txt    |  5 +----
>>  .../devicetree/bindings/net/hisilicon-hns-nic.txt     |  7 ++++---
>>  arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi          | 19 ++++++++=
+----------
>>  3 files changed, 14 insertions(+), 17 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsa=
f.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>> index 80411b2..ecacfa4 100644
>> --- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>> @@ -4,8 +4,6 @@ Required properties:
>>  - compatible: should be "hisilicon,hns-dsaf-v1" or "hisilicon,hns-d=
saf-v2".
>>    "hisilicon,hns-dsaf-v1" is for hip05.
>>    "hisilicon,hns-dsaf-v2" is for Hi1610 and Hi1612.
>> -- dsa-name: dsa fabric name who provide this interface.
>> -  should be "dsafX", X is the dsaf id.
>>  - mode: dsa fabric mode string. only support one of dsaf modes like=
 these:
>>  		"2port-64vf",
>>  		"6port-16rss",
>> @@ -26,9 +24,8 @@ Required properties:
>> =20
>>  Example:
>> =20
>> -dsa: dsa@c7000000 {
>> +dsaf0: dsa@c7000000 {
>>  	compatible =3D "hisilicon,hns-dsaf-v1";
>> -	dsa_name =3D "dsaf0";
>>  	mode =3D "6port-16rss";
>>  	interrupt-parent =3D <&mbigen_dsa>;
>>  	reg =3D <0x0 0xC0000000 0x0 0x420000
>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-nic=
=2Etxt b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
>> index 41d19be..e6a9d1c 100644
>> --- a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
>> @@ -4,8 +4,9 @@ Required properties:
>>  - compatible: "hisilicon,hns-nic-v1" or "hisilicon,hns-nic-v2".
>>    "hisilicon,hns-nic-v1" is for hip05.
>>    "hisilicon,hns-nic-v2" is for Hi1610 and Hi1612.
>> -- ae-name: accelerator name who provides this interface,
>> -  is simply a name referring to the name of name in the accelerator=
 node.
>> +- ae-handle: accelerator engine handle for hns,
>> +  specifies a reference to the associating hardware driver node.
>> +  see Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>>  - port-id: is the index of port provided by DSAF (the accelerator).=
 DSAF can
>>    connect to 8 PHYs. Port 0 to 1 are both used for adminstration pu=
rpose. They
>>    are called debug ports.
>> @@ -41,7 +42,7 @@ Example:
>> =20
>>  	ethernet@0{
>>  		compatible =3D "hisilicon,hns-nic-v1";
>> -		ae-name =3D "dsaf0";
>> +		ae-handle =3D <&dsaf0>;
>>  		port-id =3D <0>;
>>  		local-mac-address =3D [a2 14 e4 4b 56 76];
>>  	};
>> diff --git a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi b/arch/arm=
64/boot/dts/hisilicon/hip05_hns.dtsi
>> index 606dd5a..89c883e 100644
>> --- a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
>> +++ b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
>> @@ -23,9 +23,8 @@ soc0: soc@000000000 {
>>  		};
>>  	};
>> =20
>> -	dsa: dsa@c7000000 {
>> +	dsaf0: dsa@c7000000 {
>>  		compatible =3D "hisilicon,hns-dsaf-v1";
>> -		dsa_name =3D "dsaf0";
>>  		mode =3D "6port-16rss";
>>  		interrupt-parent =3D <&mbigen_dsa>;
>> =20
>> @@ -127,7 +126,7 @@ soc0: soc@000000000 {
>> =20
>>  	eth0: ethernet@0{
>>  		compatible =3D "hisilicon,hns-nic-v1";
>> -		ae-name =3D "dsaf0";
>> +		ae-handle =3D <&dsaf0>;
>>  		port-id =3D <0>;
>>  		local-mac-address =3D [00 00 00 01 00 58];
>>  		status =3D "disabled";
>> @@ -135,14 +134,14 @@ soc0: soc@000000000 {
>>  	};
>>  	eth1: ethernet@1{
>>  		compatible =3D "hisilicon,hns-nic-v1";
>> -		ae-name =3D "dsaf0";
>> +		ae-handle =3D <&dsaf0>;
>>  		port-id =3D <1>;
>>  		status =3D "disabled";
>>  		dma-coherent;
>>  	};
>>  	eth2: ethernet@2{
>>  		compatible =3D "hisilicon,hns-nic-v1";
>> -		ae-name =3D "dsaf0";
>> +		ae-handle =3D <&dsaf0>;
>>  		port-id =3D <2>;
>>  		local-mac-address =3D [00 00 00 01 00 5a];
>>  		status =3D "disabled";
>> @@ -150,7 +149,7 @@ soc0: soc@000000000 {
>>  	};
>>  	eth3: ethernet@3{
>>  		compatible =3D "hisilicon,hns-nic-v1";
>> -		ae-name =3D "dsaf0";
>> +		ae-handle =3D <&dsaf0>;
>>  		port-id =3D <3>;
>>  		local-mac-address =3D [00 00 00 01 00 5b];
>>  		status =3D "disabled";
>> @@ -158,7 +157,7 @@ soc0: soc@000000000 {
>>  	};
>>  	eth4: ethernet@4{
>>  		compatible =3D "hisilicon,hns-nic-v1";
>> -		ae-name =3D "dsaf0";
>> +		ae-handle =3D <&dsaf0>;
>>  		port-id =3D <4>;
>>  		local-mac-address =3D [00 00 00 01 00 5c];
>>  		status =3D "disabled";
>> @@ -166,7 +165,7 @@ soc0: soc@000000000 {
>>  	};
>>  	eth5: ethernet@5{
>>  		compatible =3D "hisilicon,hns-nic-v1";
>> -		ae-name =3D "dsaf0";
>> +		ae-handle =3D <&dsaf0>;
>>  		port-id =3D <5>;
>>  		local-mac-address =3D [00 00 00 01 00 5d];
>>  		status =3D "disabled";
>> @@ -174,7 +173,7 @@ soc0: soc@000000000 {
>>  	};
>>  	eth6: ethernet@6{
>>  		compatible =3D "hisilicon,hns-nic-v1";
>> -		ae-name =3D "dsaf0";
>> +		ae-handle =3D <&dsaf0>;
>>  		port-id =3D <6>;
>>  		local-mac-address =3D [00 00 00 01 00 5e];
>>  		status =3D "disabled";
>> @@ -182,7 +181,7 @@ soc0: soc@000000000 {
>>  	};
>>  	eth7: ethernet@7{
>>  		compatible =3D "hisilicon,hns-nic-v1";
>> -		ae-name =3D "dsaf0";
>> +		ae-handle =3D <&dsaf0>;
>>  		port-id =3D <7>;
>>  		local-mac-address =3D [00 00 00 01 00 5f];
>>  		status =3D "disabled";
>> --=20
>> 1.9.1
>>
> .
>
