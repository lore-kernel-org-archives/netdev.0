From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: How can i know if I/OAT is supported?
Date: Mon, 16 Jun 2008 12:17:26 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806161214540.2344@bizon.gios.gov.pl>
References: <2f3bf9a60806160351l3611d9f7jef90d51e257b059d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1892647048-1213611446=:2344"
Cc: netdev@vger.kernel.org
To: Dotan Barak <dotanba@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:34349 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693AbYFPLRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 07:17:52 -0400
In-Reply-To: <2f3bf9a60806160351l3611d9f7jef90d51e257b059d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1892647048-1213611446=:2344
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 16 Jun 2008, Dotan Barak wrote:

> Hi.
Hi,

> I'm trying to use the I/OAT technology but i don't know if the the
> sent data used this technology.
> Are there are any counters which indicates how many data was sent using I=
/OAT?

for f in /sys/class/dma/*; do echo "$f: bytes=3D`cat $f/bytes_transferred` =
count=3D`cat $f/memcpy_count`" ; done

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1892647048-1213611446=:2344--
