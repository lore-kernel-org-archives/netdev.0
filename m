From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: How can i know if I/OAT is supported?
Date: Mon, 16 Jun 2008 19:03:29 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806161758240.2344@bizon.gios.gov.pl>
References: <2f3bf9a60806160351l3611d9f7jef90d51e257b059d@mail.gmail.com>
 <Pine.LNX.4.64.0806161214540.2344@bizon.gios.gov.pl>
 <2f3bf9a60806160514y4b6259c9reb21c1df427dcf19@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-817713913-1213635809=:2344"
Cc: netdev@vger.kernel.org
To: Dotan Barak <dotanba@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:53986 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbYFPRDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 13:03:36 -0400
In-Reply-To: <2f3bf9a60806160514y4b6259c9reb21c1df427dcf19@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-817713913-1213635809=:2344
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 16 Jun 2008, Dotan Barak wrote:

> Thanks for the fast response.
>
>>> I'm trying to use the I/OAT technology but i don't know if the the
>>> sent data used this technology.
>>> Are there are any counters which indicates how many data was sent using
>>> I/OAT?
>>
>> for f in /sys/class/dma/*; do echo "$f: bytes=3D`cat $f/bytes_transferre=
d`
>> count=3D`cat $f/memcpy_count`" ; done
>
> I have the folder /sys/class/dma/, but this folder is empty.
> What does it mean?

dmesg |grep -i ioatdma

?

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-817713913-1213635809=:2344--
