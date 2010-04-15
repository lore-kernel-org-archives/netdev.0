From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix softnet_stat
Date: Thu, 15 Apr 2010 05:40:46 +0200
Message-ID: <1271302846.16881.1828.camel@edumazet-laptop>
References: <1271300513-9995-1-git-send-email-xiaosuo@gmail.com>
	 <1271302133.16881.1814.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:47631 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756730Ab0DODky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 23:40:54 -0400
Received: by bwz25 with SMTP id 25so985256bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 20:40:53 -0700 (PDT)
In-Reply-To: <1271302133.16881.1814.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 05:28 +0200, Eric Dumazet a =C3=A9crit :
> > =20
> > +	per_cpu(netdev_rx_stat, cpu).dropped++;
>=20
> This is a bit expensive, and could be a queue->rx_stat.dropped++
> if netdev_rx_stat is moved inside queue structure.

Hmm, this is not really needed, this event is the slow path and should
almost never happen. This part of your fix is fine.


