From: Krzysztof Oledzki <ole@ans.pl>
Subject: RE: How can i know if I/OAT is supported?
Date: Mon, 16 Jun 2008 17:56:48 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806161754130.2344@bizon.gios.gov.pl>
References: <7F38996F7185A24AB9071ED4950AD8C101B3CA6E@swsmsx413.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-633230102-1213631808=:2344"
Cc: dotanba@gmail.com, olel@ans.pl, netdev@vger.kernel.org
To: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:53730 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756617AbYFPQ5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 12:57:48 -0400
In-Reply-To: <7F38996F7185A24AB9071ED4950AD8C101B3CA6E@swsmsx413.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-633230102-1213631808=:2344
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 16 Jun 2008, Sosnowski, Maciej wrote:

> Hi Dotan,
>
>>>> I'm trying to use the I/OAT technology but i don't know if the the
>>>> sent data used this technology.
>>>> Are there are any counters which indicates how many data was sent
> using
>>>> I/OAT?
>>>
>>> for f in /sys/class/dma/*; do echo "$f: bytes=3D`cat
> $f/bytes_transferred`
>>> count=3D`cat $f/memcpy_count`" ; done
>>
>> I have the folder /sys/class/dma/, but this folder is empty.
>> What does it mean?
>
> It means that you do not have ioatdma module loaded.
> Simply try: modprobe ioatdma.
> If driver installs correctly, you should see statistics in
> /sys/class/dma/

Are you sure? From my experience it looks like the driver is loaded yet it=
=20
was not able to find a supported device or initialize it.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-633230102-1213631808=:2344--
