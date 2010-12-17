From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ifb: fix a lockdep splat
Date: Fri, 17 Dec 2010 14:15:50 +0100
Message-ID: <1292591750.2906.13.camel@edumazet-laptop>
References: <1292493175.2883.56.camel@edumazet-laptop>
	 <1292591398.2668.20.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56485 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220Ab0LQNPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 08:15:55 -0500
Received: by wyb28 with SMTP id 28so599438wyb.19
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 05:15:53 -0800 (PST)
In-Reply-To: <1292591398.2668.20.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 d=C3=A9cembre 2010 =C3=A0 08:09 -0500, jamal a =C3=A9cri=
t :
> On Thu, 2010-12-16 at 10:52 +0100, Eric Dumazet wrote:
> > After recent ifb changes, we must use lockless __skb_dequeue() sinc=
e
> > lock is not anymore initialized.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Jamal Hadi Salim <hadi@cyberus.ca>
> > Cc: Changli Gao <xiaosuo@gmail.com>
>=20
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Thanks for reviewing Jamal !


