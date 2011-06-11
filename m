From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Sat, 11 Jun 2011 14:17:24 +0800
Message-ID: <BANLkTim4ikjYJjdW8AWjmPi8hx-a0nh=Ug@mail.gmail.com>
References: <1307600810.3980.85.camel@edumazet-laptop> <1307664235.17300.44.camel@schen9-DESK>
 <20110609.204330.2090335955971650557.davem@davemloft.net> <1307745190.17300.85.camel@schen9-DESK>
 <BANLkTikU_ug=zUdfOZAX6eJ+BD9ZZvDrJA@mail.gmail.com> <1307768052.2872.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Chen <tim.c.chen@linux.intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	andi@firstfloor.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50869 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107Ab1FKGRp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 02:17:45 -0400
Received: by bwz15 with SMTP id 15so2674600bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 23:17:44 -0700 (PDT)
In-Reply-To: <1307768052.2872.50.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 11, 2011 at 12:54 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le samedi 11 juin 2011 =E0 08:54 +0800, Changli Gao a =E9crit :
>
>
> Whole point of the exercice is to prepare ground for routing cache
> removal :)
>
> If you want a server being hit by millions of clients around the worl=
d,
> routing cache is a real pain because of memory needs.
>

Yes. I know the routing cache removal is our goal. But for his
scenario, there aren't so many routing cache entries, so routing cache
may be a better option currently. However, if he just wants to
evaluate the effect of the routing cache removal, it is another thing.
:)

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
