From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH 8/9] ARM: berlin: Add phy-connection-type to BG2Q PHY
Date: Tue, 21 Oct 2014 13:46:30 +0200
Message-ID: <54464796.90804@gmail.com>
References: <1413881627-21639-1-git-send-email-sebastian.hesselbarth@gmail.com> <1413881627-21639-9-git-send-email-sebastian.hesselbarth@gmail.com> <54464401.20900@cogentembedded.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?QW50b2luZSBUw6luYXJ0?=
	<antoine.tenart@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Eric Miao <eric.y.miao@gmail.com>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54464401.20900@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.10.2014 13:31, Sergei Shtylyov wrote:
> Hello.
>
> On 10/21/2014 12:53 PM, Sebastian Hesselbarth wrote:
>
>> From: Antoine T=C3=A9nart <antoine.tenart@free-electrons.com>
>
>> Internal FastEthernet PHY on BG2Q is connected via MII, add a
>> corresponding phy-connection-type property.
>
>> Tested-by: Antoine T=C3=A9nart <antoine.tenart@free-electrons.com>
>> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.co=
m>
>> ---
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: "Antoine T=C3=A9nart" <antoine.tenart@free-electrons.com>
>> Cc: Florian Fainelli <f.fainelli@gmail.com>
>> Cc: Eric Miao <eric.y.miao@gmail.com>
>> Cc: Haojian Zhuang <haojian.zhuang@gmail.com>
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: netdev@vger.kernel.org
>> Cc: devicetree@vger.kernel.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>>   arch/arm/boot/dts/berlin2q.dtsi | 1 +
>>   1 file changed, 1 insertion(+)
>
>> diff --git a/arch/arm/boot/dts/berlin2q.dtsi
>> b/arch/arm/boot/dts/berlin2q.dtsi
>> index 891d56b03922..6dbc520bddc1 100644
>> --- a/arch/arm/boot/dts/berlin2q.dtsi
>> +++ b/arch/arm/boot/dts/berlin2q.dtsi
>> @@ -127,6 +127,7 @@
>>               status =3D "disabled";
>>
>>               ethphy0: ethernet-phy@0 {
>> +                phy-connection-type =3D "mii";
>
>     You're adding this prop to the PHY node? That's very weird...
> normally, it's a property of a MDIO bus node.

Sergei,

How can this be a property of the MDIO bus node? Just think of an MDIO
bus with two PHYs where one is connected via GMII and the other via
RGMII? How should this work?

But you are right that the property should not be part of the PHY node
but the controller node instead. I'll rework and send an update, thanks
for the hint.

Sebastian
