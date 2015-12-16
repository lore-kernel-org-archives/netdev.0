From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v3] net/macb: add support for resetting PHY using GPIO
Date: Wed, 16 Dec 2015 20:09:39 +0100
Message-ID: <878u4utdl8.fsf@free-electrons.com>
References: <1450290690-32369-1-git-send-email-gregory.clement@free-electrons.com>
	<20151216190431.GB28759@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Russell King <linux@arm.linux.org.uk>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151216190431.GB28759@localhost.localdomain> (Richard Cochran's
	message of "Wed, 16 Dec 2015 20:04:31 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,
=20
 On mer., d=C3=A9c. 16 2015, Richard Cochran <richardcochran@gmail.com>=
 wrote:

> On Wed, Dec 16, 2015 at 07:31:30PM +0100, Gregory CLEMENT wrote:
>> +Optional properties for PHY child node:
>> +- reset-gpios : Should specify the gpio for phy reset
>
> reset-gpios plural or reset-gpio singular?

The bindings name is plural but it handle only one gpio.

See:
https://lkml.org/lkml/2015/12/9/623

>
>> +
>>  Examples:
>> =20
>>  	macb0: ethernet@fffc4000 {
>> @@ -29,4 +32,8 @@ Examples:
>>  		local-mac-address =3D [3a 0e 03 04 05 06];
>>  		clock-names =3D "pclk", "hclk", "tx_clk";
>>  		clocks =3D <&clkc 30>, <&clkc 30>, <&clkc 13>;
>> +		ethernet-phy@1 {
>> +			reg =3D <0x1>;
>> +			reset-gpios =3D <&pioE 6 1>;
>
> Did you mean "gpioE" ?

No, I really mean pioE: it is the name used for the at91 SoCs.

Thanks,

Gregory

--=20
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
