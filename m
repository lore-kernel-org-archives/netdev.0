From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 2/2] udp: add sk opt to allow sending pkt
 with src 0.0.0.0
Date: Thu, 14 Nov 2013 14:57:08 -0500 (EST)
Message-ID: <20131114.145708.640925730076403111.davem@davemloft.net>
References: <1383958474-6255-2-git-send-email-nicolas.dichtel@6wind.com>
	<20131111.001803.110603937316567461.davem@davemloft.net>
	<5284CA7C.7030402@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, jiri@resnulli.us, vyasevich@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, thaller@redhat.com, stephen@networkplumber.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755842Ab3KNT5O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 14:57:14 -0500
In-Reply-To: <5284CA7C.7030402@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 14 Nov 2013 14:05:00 +0100

> Le 11/11/2013 06:18, David Miller a =E9crit :
>> Furthermore, the fact that you're implementing _addressing_ policy i=
n
>> the UDP code makes this change even more unreasonable.
>>
> I made this choice because using 0.0.0.0, for TCP for example, seems =
a
> non-sense.

It's at the very least something applicable to all datagram sockets.
