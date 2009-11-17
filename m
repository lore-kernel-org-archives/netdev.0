From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Tue, 17 Nov 2009 13:38:29 +0800
Message-ID: <412e6f7f0911162138k6537afd1l5f8eeeaa6c636289@mail.gmail.com>
References: <4AFBD911.6000900@gmail.com> <4AFCE273.7010901@gmail.com>
	 <20091116083905.634b8f56@nehalam>
	 <20091116.191054.131722163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, kaber@trash.net, eric.dumazet@gmail.com,
	therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:33552 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbZKQFiY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 00:38:24 -0500
Received: by pwi3 with SMTP id 3so3750544pwi.21
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 21:38:30 -0800 (PST)
In-Reply-To: <20091116.191054.131722163.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 17, 2009 at 11:10 AM, David Miller <davem@davemloft.net> wr=
ote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 16 Nov 2009 08:39:05 -0800
>
>> My $.02 is that receive packet steering RPS should be done generical=
ly at
>> receive layer. Then all the CPU, mapping and configuration issues ca=
n be
>> done once, not just for IFB, Bridge, VLAN, ... The number of users o=
f IFB
>> is small, and setup is complex. Steering packets in IFB is optimizin=
g only
>> a rarely used corner.
>>
>> Layered link services like IFB need to be multi-threaded lockless to=
 maintain
>> the advantages of multi-queue and RPS.
>
> You're probably right.
>

So I have to wait RPS, and after it gets merged, I'll back with
multi-threaded lockless IFB.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
