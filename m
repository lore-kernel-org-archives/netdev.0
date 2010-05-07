From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Increase NET_SKB_PAD to 64 bytes
Date: Fri, 07 May 2010 11:55:14 +0200
Message-ID: <1273226114.2261.42.camel@edumazet-laptop>
References: <20100506.220221.90798296.davem@davemloft.net>
	 <1273209321.2222.36.camel@edumazet-laptop>	<4BE3C70C.4060705@monstr.eu>
	 <20100507.013216.133893678.davem@davemloft.net>  <4BE3E1D6.30907@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hadi@cyberus.ca, therbert@google.com,
	microblaze-uclinux@itee.uq.edu.au
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:52580 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753670Ab0EGJzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 05:55:18 -0400
Received: by bwz19 with SMTP id 19so466712bwz.21
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 02:55:16 -0700 (PDT)
In-Reply-To: <4BE3E1D6.30907@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 mai 2010 =C3=A0 11:48 +0200, Michal Simek a =C3=A9crit :
> David Miller wrote:
> > From: Michal Simek <monstr@monstr.eu>
> > Date: Fri, 07 May 2010 09:53:48 +0200
> >=20
> >> I will add this Microblaze patch to my repo for testing and anyway
> >> should go through my repo.
> >=20
> > It's already in the net-next-2.6 tree.
>=20
> Anyway.
>=20
> I am ok with removing NET_IP_ALIGN because it is already defined in=20
> skbuff.h to 2.
> But increasing NET_SKB_PAD to 64 caused that Microblaze extends skb=20
> buffers for some bytes.
> I measured it by iperf and netperf and I see regression around 1-2Mbi=
t/s=20
> that's why I would like to ask you to revert this patch or keep at le=
ast=20
> NET_SKB_PAD part.

Interesting.

Increasing NET_SKB_PAD to say 128 or 256 should not have performance
impact, but reserve a bit more ram. (truesize...)

Investigation is needed. Maybe your NIC now allocates high order pages =
?

What driver are you using ?


