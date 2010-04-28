From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Wed, 28 Apr 2010 16:19:28 +0200
Message-ID: <1272464368.2267.72.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272018366.7895.7930.camel@edumazet-laptop>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:59436 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab0D1OTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 10:19:34 -0400
Received: by bwz19 with SMTP id 19so15889bwz.21
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 07:19:33 -0700 (PDT)
In-Reply-To: <1272463605.2267.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 28 avril 2010 =C3=A0 16:06 +0200, Eric Dumazet a =C3=A9crit=
 :
> Le mercredi 28 avril 2010 =C3=A0 08:36 -0400, jamal a =C3=A9crit :
> > On Wed, 2010-04-28 at 14:33 +0200, Eric Dumazet wrote:
> >=20
> > > If you wait a bit, I have another patch to speedup udp receive pa=
th ;)
> >=20
> > Shoot whenever you are ready ;-> I will test with and without your
> > patch..
> >=20
>=20
> Here it is ;)
>=20
> Thanks

I forgot to say that with my previous DDOS test/bench (16 cpus trying t=
o
feed one udp socket), my receiver can now process 420.000 pps instead o=
f
200.000 ;)



