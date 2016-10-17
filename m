From: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Subject: Re: [PATCH 4/4] gpio: ptxpmb-ext-cpld: Document bindings of PTXPMB extended CPLD
Date: Mon, 17 Oct 2016 22:10:01 +0300
Message-ID: <FECF48A5-4540-4370-B2E1-5EEC10EEA22B@konsulko.com>
References: <1475853574-22339-1-git-send-email-pantelis.antoniou@konsulko.com> <1475853574-22339-5-git-send-email-pantelis.antoniou@konsulko.com> <20161010201936.GB32418@rob-hp-laptop>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161010201936.GB32418@rob-hp-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rob,

> On Oct 10, 2016, at 23:19 , Rob Herring <robh@kernel.org> wrote:
>=20
> On Fri, Oct 07, 2016 at 06:19:34PM +0300, Pantelis Antoniou wrote:
>> From: Georgi Vlaev <gvlaev@juniper.net>
>>=20
>> Add device tree bindings document for the GPIO driver of
>> Juniper's PTXPMB extended CPLD.
>>=20
>> Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
>> [Ported from Juniper kernel]
>> Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
>> ---
>> .../bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt     | 36 =
++++++++++++++++++++++
>> 1 file changed, 36 insertions(+)
>> create mode 100644 =
Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt
>>=20
>> diff --git =
a/Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt =
b/Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt
>> new file mode 100644
>> index 0000000..87f01b9
>> --- /dev/null
>> +++ =
b/Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt
>> @@ -0,0 +1,36 @@
>> +Juniper PTXPMB extended CPLD GPIO block
>> +
>> +Required properties:
>> +
>> +- compatible:
>> +    Must be "jnx,gpio-ptxpmb-ext-cpld"
>=20
> Generally, '-gpio' would be last.
>=20

OK.


>> +
>> +- #gpio-cells:
>> +    Should be <2>.  The first cell is the pin number (within the =
controller's
>> +    pin space), and the second is used for the following flags:
>> +	bit[0]: direction (0 =3D out, 1 =3D in)
>> +	bit[1]: init high
>> +	bit[2]: active low
>=20
> Same comment as all the other gpio bindings...
>=20
>> +
>> +- gpio-controller:
>> +    Specifies that the node is a GPIO controller.
>> +
>> +- interrupt-controller:
>> +    Specifies that the node is an interrupt controller.
>> +
>> +Optional properties:
>> +
>> +- reg:
>> +    Address and length of the register set for the device. Usually =
supplied
>> +    by the parent MFD device.
>=20
> Make it required.
>=20

Hmm, the current driver supplies that range via platform data (it=E2=80=99=
s an mfd driver).
What=E2=80=99s the take on mixing those?

>> +
>> +
>> +Example:
>> +
>> +gpio_ext_cpld: cpld-ext-gpio {
>> +	compatible =3D "jnx,gpio-ptxpmb-ext-cpld";
>> +	#gpio-cells =3D <2>;
>> +	#interrupt-cells =3D <2>;
>> +	gpio-controller;
>> +	interrupt-controller;
>> +};
>> --=20
>> 1.9.1
