From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: How can i know if I/OAT is supported?
Date: Tue, 17 Jun 2008 09:05:41 +0100
Message-ID: <7F38996F7185A24AB9071ED4950AD8C101B3CD2F@swsmsx413.ger.corp.intel.com>
References: <Pine.LNX.4.64.0806161754130.2344@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <dotanba@gmail.com>, <olel@ans.pl>, <netdev@vger.kernel.org>
To: "Krzysztof Oledzki" <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13446 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440AbYFQIFu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 04:05:50 -0400
Content-class: urn:content-classes:message
In-Reply-To: <Pine.LNX.4.64.0806161754130.2344@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki wrote:
> On Mon, 16 Jun 2008, Sosnowski, Maciej wrote:
>=20
>> Hi Dotan,
>>=20
>>>>> I'm trying to use the I/OAT technology but i don't know if the th=
e
>>>>> sent data used this technology.
>>>>> Are there are any counters which indicates how many data was sent=
 using
>>>>> I/OAT?
>>>>=20
>>>> for f in /sys/class/dma/*; do echo "$f: bytes=3D`cat $f/bytes_tran=
sferred`
>>>> count=3D`cat $f/memcpy_count`" ; done
>>>=20
>>> I have the folder /sys/class/dma/, but this folder is empty.
>>> What does it mean?
>>=20
>> It means that you do not have ioatdma module loaded. Simply try: mod=
probe
>> ioatdma. If driver installs correctly, you should see statistics in
>> /sys/class/dma/
>=20
> Are you sure? From my experience it looks like the driver is loaded y=
et it
> was not able to find a supported device or initialize it.
>=20
> Best regards,
>=20
>  				Krzysztof Ol=EAdzki

Yes, that's why I have written "if driver installs correctly"=20
(sorry, I should have put it "initializes correctly").
Anyway, to make it clear, empty /sys/class/dma/ means that=20
either ioatdma is not loaded at all or its initialization failed.

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

