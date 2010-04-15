From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: fix softnet_stat
Date: Thu, 15 Apr 2010 11:45:39 +0800
Message-ID: <i2o412e6f7f1004142045ie1337a77h3d13ab48393f374c@mail.gmail.com>
References: <1271300513-9995-1-git-send-email-xiaosuo@gmail.com>
	<1271302133.16881.1814.camel@edumazet-laptop> <1271302846.16881.1828.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f227.google.com ([209.85.217.227]:47341 "EHLO
	mail-gx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757060Ab0DODqB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 23:46:01 -0400
Received: by gxk27 with SMTP id 27so650960gxk.1
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 20:45:59 -0700 (PDT)
In-Reply-To: <1271302846.16881.1828.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 11:40 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 15 avril 2010 =C3=A0 05:28 +0200, Eric Dumazet a =C3=A9crit =
:
>> >
>> > + =C2=A0 per_cpu(netdev_rx_stat, cpu).dropped++;
>>
>> This is a bit expensive, and could be a queue->rx_stat.dropped++
>> if netdev_rx_stat is moved inside queue structure.
>
> Hmm, this is not really needed, this event is the slow path and shoul=
d
> almost never happen. This part of your fix is fine.
>

It there any document about /proc/net/softnet_stat?


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
