From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Hight speed data sending from custom IP out of kernel
Date: Thu, 21 Apr 2011 10:18:45 +0200
Message-ID: <1303373925.3685.6.camel@edumazet-laptop>
References: <53f539ea861e1a24bde4aadceff0b3bb.squirrel@www.liukuma.net>
	 <4DAD76F1.40309@monstr.eu>
	 <45cb2254ff23a4977c95b0f9459e39a6.squirrel@www.liukuma.net>
	 <4DAFE4A0.2030905@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: juice@swagman.org, netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45518 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343Ab1DUISw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 04:18:52 -0400
Received: by wya21 with SMTP id 21so1221847wya.19
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 01:18:51 -0700 (PDT)
In-Reply-To: <4DAFE4A0.2030905@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 21 avril 2011 =C3=A0 10:02 +0200, Michal Simek a =C3=A9crit :

> Thanks for that. I am looking at pktgen. On UDP my system is able to =
send full=20
> bandwidth on 100Mbit/s ethernet and 220Mbit/s on 1G/s.
> I will let you know when I have any useful resutls.

220Mbits/s in pktgen or an application ?
- how many packets per second ? (or packet size ?)

pktgen has the "clone_skb 100" thing that avoid skb_alloc()/skb_free()
overhead, and permits to really test driver performance.

It also bypass qdisc management.



