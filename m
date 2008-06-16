From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: How can i know if I/OAT is supported?
Date: Mon, 16 Jun 2008 15:37:00 +0100
Message-ID: <7F38996F7185A24AB9071ED4950AD8C101B3CA6E@swsmsx413.ger.corp.intel.com>
References: <f12847240806160708r33d509cfnfe77dde32b0d7709@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <olel@ans.pl>, <netdev@vger.kernel.org>
To: <dotanba@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5746 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757733AbYFPOhR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 10:37:17 -0400
Content-class: urn:content-classes:message
In-Reply-To: <f12847240806160708r33d509cfnfe77dde32b0d7709@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dotan,

>>> I'm trying to use the I/OAT technology but i don't know if the the
>>> sent data used this technology.
>>> Are there are any counters which indicates how many data was sent
using
>>> I/OAT?
>> 
>> for f in /sys/class/dma/*; do echo "$f: bytes=`cat
$f/bytes_transferred`
>> count=`cat $f/memcpy_count`" ; done
> 
> I have the folder /sys/class/dma/, but this folder is empty.
> What does it mean?

It means that you do not have ioatdma module loaded.
Simply try: modprobe ioatdma.
If driver installs correctly, you should see statistics in
/sys/class/dma/

> 
> thanks
> Dotan

Regards,
Maciej

---------------------------------------------------------------------
Intel Technology Poland sp. z o.o.
z siedziba w Gdansku
ul. Slowackiego 173
80-298 Gdansk

Sad Rejonowy Gdansk Polnoc w Gdansku, 
VII Wydzial Gospodarczy Krajowego Rejestru Sadowego, 
numer KRS 101882

NIP 957-07-52-316
Kapital zakladowy 200.000 zl

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

