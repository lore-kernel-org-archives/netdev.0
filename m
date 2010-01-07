From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] lib/vsprintf.c: Add %pMF to format FDDI bit reversed MAC
	addresses
Date: Thu, 7 Jan 2010 22:13:18 +0100
Message-ID: <e2d7436a1001071313r6f5814c9o9d7b2d1c6e162367@mail.gmail.com>
References: <BD79186B4FD85F4B8E60E381CAEE19090208954A@mi8nycmail19.Mi8.com>
	 <1262888625.10429.23.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1001072037170.13474@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>,
	H Hartley Sweeten <hartleys@visionengravers.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754044Ab0AGVNV@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1001072037170.13474@eddie.linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/1/7 Maciej W. Rozycki <macro@linux-mips.org>:
> On Thu, 7 Jan 2010, Joe Perches wrote:
>> On Mon, 2010-01-04 at 23:43 +0000, Maciej W. Rozycki wrote:
>> > The example below shows an address, and the sequence of bits or sy=
mbols
>> > that would be transmitted when the address is used in the Source A=
ddress
>> > or Destination Address fields on the MAC header. =A0The transmissi=
on line
>> > shows the address bits in the order transmitted, from left to righ=
t. =A0For
>> > IEEE 802 LANs these correspond to actual bits on the medium. =A0Th=
e FDDI
>> > symbols line shows how the FDDI PHY sends the address bits as enco=
ded
>> > symbols.
>> >
>> > =A0 =A0 =A0 =A0 MSB: =A0 =A0 =A0 =A0 =A0 =A035:7B:12:00:00:01
>> > =A0 =A0 =A0 =A0 Canonical: =A0 =A0 =A0AC-DE-48-00-00-80
>> > =A0 =A0 =A0 =A0 Transmission: =A0 00110101 01111011 00010010 00000=
000 00000000 00000001
>> > =A0 =A0 =A0 =A0 FDDI Symbols: =A0 35 7B 12 00 00 01"
>> >
>> > Please note that this address has its group bit clear.
>> >
>> > =A0This notation is also defined in the "FDDI MEDIA ACCESS CONTROL=
-2
>> > (MAC-2)" (X3T9/92-120) document although that book does not have a=
 need
>> > to use the MSB form and it's skipped.
>>
>> Adds 56 bytes to object size
>>
>> New:
>> $ size lib/vsprintf.o
>> =A0 =A0text =A0 =A0 =A0 =A0 =A0data =A0 =A0 bss =A0 =A0 dec =A0 =A0 =
hex filename
>> =A0 =A08714 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 2 =A0 =A08716 =A0 =
=A0220c lib/vsprintf.o
>> old:
>> $ size lib/vsprintf.o
>> =A0 =A0text =A0 =A0 =A0 =A0 =A0data =A0 =A0 bss =A0 =A0 dec =A0 =A0 =
hex filename
>> =A0 =A08658 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 2 =A0 =A08660 =A0 =
=A021d4 lib/vsprintf.o
>
> =A0What's the gain? =A0I'd be rather conservative when taking everybo=
dy's 56
> bytes for one or two drivers hardly anybody uses. =A0The format of MA=
C
> addresses is unlikely to change, so I'd say the sources can live with
> one or two places where the strings are formatted manually. =A0Even i=
f the
> drivers lose more than these 56 bytes.

Maybe this can be Kconfig-selected by the relevant drivers then?

BTW, the gain is of course consistency and code readability.

Best Regards,
Micha=B3 Miros=B3aw
