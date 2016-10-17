From: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Subject: Re: [PATCH 2/4] mfd: ptxpmb-ext-cpld: Add documentation for PTXPMB extended CPLD
Date: Mon, 17 Oct 2016 22:08:54 +0300
Message-ID: <96110C7A-A2F6-44A6-A72E-2B2E2A800AD6@konsulko.com>
References: <1475853574-22339-1-git-send-email-pantelis.antoniou@konsulko.com> <1475853574-22339-3-git-send-email-pantelis.antoniou@konsulko.com> <20161010201031.GA31318@rob-hp-laptop>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Lee Jones <lee.jones@linaro.org>,
        Linus Walleij <linus.walleij@linaro.org>,
        Alexandre Courbot <gnurou@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Frank Rowand <frowand.list@gmail.com>,
        Georgi Vlaev <gvlaev@juniper.net>,
        Guenter Roeck <linux@roeck-us.net>,
        JawaharBalaji Thirumalaisamy <jawaharb@juniper.net>,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-gpio@vger.kernel.org, linux-i2c@vger.kernel.org,
        linux-mtd@lists.infradead.org, linux-watchdog@vger.kernel.org,
        netdev@vger.kernel.org
To: Rob Herring <robh@kernel.org>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <20161010201031.GA31318@rob-hp-laptop>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rob,

> On Oct 10, 2016, at 23:10 , Rob Herring <robh@kernel.org> wrote:
>=20
> On Fri, Oct 07, 2016 at 06:19:32PM +0300, Pantelis Antoniou wrote:
>> From: Georgi Vlaev <gvlaev@juniper.net>
>>=20
>> Add DT bindings document for the PTXPMB extended CPLD device.
>>=20
>> Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
>> [Ported from Juniper kernel]
>> Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
>> ---
>> .../bindings/mfd/jnx-ptxpmb-ext-cpld.txt           | 35 =
++++++++++++++++++++++
>> 1 file changed, 35 insertions(+)
>> create mode 100644 =
Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt
>>=20
>> diff --git =
a/Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt =
b/Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt
>> new file mode 100644
>> index 0000000..098a548a
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt
>> @@ -0,0 +1,35 @@
>> +* Device tree bindings for Juniper's PTXPMB Extended CPLD FPGA MFD =
driver
>> +
>> +The device supports a gpio block which is described in the
>> +jnx-gpio-ptxpmb-ext-cpld document.
>> +
>> +Required properties:
>> +
>> +- compatible:		"jnx,ptxpmb-ext-cpld"
>> +
>> +- reg:			contains offset/length value for device =
state control
>> +			registers space.
>> +
>> +Optional properties:
>> +
>> +- interrupts:		The interrupt line(s) the /IRQ signal(s) =
for the device is
>> +			connected to.
>> +
>> +- interrupt-parent:	The parent interrupt controller.
>> +
>> +Example:
>> +
>> +ext-cpld@1,0 {
>> +	compatible =3D "jnx,ptxpmb-ext-cpld";
>> +	reg =3D <0x1 0 0x1000>;
>=20
> What's the bus type here? Unit address is probably wrong.
>=20

localbus on a gpmc memory controller.

>> +	interrupt-parent =3D <&mpic>;
>> +	interrupts =3D <7 2>, <8 2>;
>> +
>> +	gpio_ext_cpld: cpld-ext-gpio {
>> +		compatible =3D "jnx,gpio-ptxpmb-ext-cpld";
>> +		#gpio-cells =3D <2>;
>> +		#interrupt-cells =3D <2>;
>> +		gpio-controller;
>> +		interrupt-controller;
>> +	};
>> +};
>> --=20
>> 1.9.1

