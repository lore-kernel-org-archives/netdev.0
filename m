From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] drivers/net : avoid some skb->ip_summed
 initializations
Date: Fri, 03 Sep 2010 07:17:21 +0200
Message-ID: <1283491041.3699.1350.camel@edumazet-laptop>
References: <20100902.123801.102553189.davem@davemloft.net>
	 <1283457301.3699.117.camel@edumazet-laptop>
	 <20100902.130801.232752770.davem@davemloft.net>
	 <20100902.190733.116374097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56613 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab0ICFR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 01:17:28 -0400
Received: by wwj40 with SMTP id 40so1970706wwj.1
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 22:17:27 -0700 (PDT)
In-Reply-To: <20100902.190733.116374097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 septembre 2010 =C3=A0 19:07 -0700, David Miller a =C3=A9cri=
t :

> You really didn't compile test this with the debugging actually
> enabled, did you? :-)
>=20
> I fixed the BUG() to be a BUG_ON().

Indeed, you are right ;)

Thanks !


