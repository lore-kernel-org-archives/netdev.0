From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use skb_get_rxhash()
Date: Tue, 24 Aug 2010 16:09:51 +0200
Message-ID: <1282658991.2477.233.camel@edumazet-laptop>
References: <1282643558-20866-1-git-send-email-xiaosuo@gmail.com>
	 <1282645262.2477.64.camel@edumazet-laptop>
	 <AANLkTi=AkO0hUZ7o3uwX5zrxeiLi1TsLzu5QL=pUrAju@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47297 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953Ab0HXOKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 10:10:05 -0400
Received: by wwe15 with SMTP id 15so1941697wwe.1
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 07:10:03 -0700 (PDT)
In-Reply-To: <AANLkTi=AkO0hUZ7o3uwX5zrxeiLi1TsLzu5QL=pUrAju@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 ao=C3=BBt 2010 =C3=A0 21:53 +0800, Changli Gao a =C3=A9crit=
 :

> However, do we really need to check if skb->sk->sk_hash is zero? It i=
s
> a rare case, and this check may mislead someone to think a non zero
> sk_hash means that sk_hash is set.
>=20

Not sure what you mean ;)

sk_hash is not always filled, only for some kind of sockets (tcp, udp)



