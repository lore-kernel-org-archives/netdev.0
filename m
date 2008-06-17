From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: How can i know if I/OAT is supported?
Date: Tue, 17 Jun 2008 10:05:17 +0100
Message-ID: <7F38996F7185A24AB9071ED4950AD8C101B3CE45@swsmsx413.ger.corp.intel.com>
References: <2f3bf9a60806170113r219b49ffjfcfa9fd68008cf8f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Krzysztof Oledzki" <ole@ans.pl>, <olel@ans.pl>,
	<netdev@vger.kernel.org>
To: "Dotan Barak" <dotanba@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35920 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752803AbYFQJFg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 05:05:36 -0400
Content-class: urn:content-classes:message
In-Reply-To: <2f3bf9a60806170113r219b49ffjfcfa9fd68008cf8f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dotan Barak wrote:
> 2008/6/17 Sosnowski, Maciej <maciej.sosnowski@intel.com>:
>> Krzysztof Oledzki wrote:
>>> On Mon, 16 Jun 2008, Sosnowski, Maciej wrote:
>>>=20
>>>> Hi Dotan,
>>>>=20
>>>>>>> I'm trying to use the I/OAT technology but i don't know if the =
the
>>>>>>> sent data used this technology.
>>>>>>> Are there are any counters which indicates how many data was se=
nt using
>>>>>>> I/OAT?
>>>>>>=20
>>>>>> for f in /sys/class/dma/*; do echo "$f: bytes=3D`cat $f/bytes_tr=
ansferred`
>>>>>> count=3D`cat $f/memcpy_count`" ; done
>>>>>=20
>>>>> I have the folder /sys/class/dma/, but this folder is empty.
>>>>> What does it mean?
>>>>=20
>>>> It means that you do not have ioatdma module loaded. Simply try: m=
odprobe
>>>> ioatdma. If driver installs correctly, you should see statistics i=
n
>>>> /sys/class/dma/
>>>=20
>>> Are you sure? From my experience it looks like the driver is loaded=
 yet it
>>> was not able to find a supported device or initialize it.
>>>=20
>>> Best regards,
>>>=20
>>>                               Krzysztof Ol=EAdzki
>>=20
>> Yes, that's why I have written "if driver installs correctly"
>> (sorry, I should have put it "initializes correctly").
>> Anyway, to make it clear, empty /sys/class/dma/ means that
>> either ioatdma is not loaded at all or its initialization failed.
>>=20
>> Regards,
>> Maciej
>=20
> O.k., so now I/OAT is not compiled as part of the kernel and i'm
> loading the updated driver but still
> i don't see any file in this folder...
> (the module is loaded)
>=20
> How can i know if my chipset/BIOS/CPU support I/OAT?
>=20
> thanks
> Dotan

You should check your PCI devices and see if you can find DMA Engine th=
ere.
One of following vendor:device should be there ("lspci -n")=20
if your chipset supports I/OAT: 8086:1a38, 8086:360b, 8086:65ff, 8086:4=
02f.

Apart from that, if the driver finds I/OAT device,=20
you should see "Intel(R) I/OAT DMA Engine found" kernel message.

Regards,
Maciej
---------------------------------------------------------------------
Intel Technology Poland sp. z o.o.
z siedziba w Gdansku
ul. Slowackiego 173
80-298 Gdansk

Sad Rejonowy Gdansk Polnoc w Gdansku,=20
VII Wydzial Gospodarczy Krajowego Rejestru Sadowego,=20
numer KRS 101882

NIP 957-07-52-316
Kapital zakladowy 200.000 zl

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

