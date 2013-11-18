From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 2/2] udp: add sk opt to allow sending pkt
 with src 0.0.0.0
Date: Mon, 18 Nov 2013 10:15:24 +0100
Message-ID: <5289DAAC.6050506@6wind.com>
References: <1383958474-6255-2-git-send-email-nicolas.dichtel@6wind.com>	<20131111.001803.110603937316567461.davem@davemloft.net>	<5284CA7C.7030402@6wind.com> <20131114.145708.640925730076403111.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, jiri@resnulli.us, vyasevich@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, thaller@redhat.com, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:38756 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713Ab3KRJPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 04:15:30 -0500
Received: by mail-wg0-f45.google.com with SMTP id a1so5999314wgh.24
        for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 01:15:29 -0800 (PST)
In-Reply-To: <20131114.145708.640925730076403111.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/11/2013 20:57, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Thu, 14 Nov 2013 14:05:00 +0100
>
>> Le 11/11/2013 06:18, David Miller a =E9crit :
>>> Furthermore, the fact that you're implementing _addressing_ policy =
in
>>> the UDP code makes this change even more unreasonable.
>>>
>> I made this choice because using 0.0.0.0, for TCP for example, seems=
 a
>> non-sense.
>
> It's at the very least something applicable to all datagram sockets.
Yes, right.
