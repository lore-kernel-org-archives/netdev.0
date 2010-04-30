From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Fri, 30 Apr 2010 22:40:00 +0200
Message-ID: <1272660000.2230.4.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
	 <1272548980.2222.87.camel@edumazet-laptop> <1272549408.4258.189.camel@bigi>
	 <1272573383.3969.8.camel@bigi>  <1272655814.3879.8.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:34651 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759068Ab0D3UkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 16:40:06 -0400
Received: by bwz19 with SMTP id 19so361985bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 13:40:05 -0700 (PDT)
In-Reply-To: <1272655814.3879.8.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 30 avril 2010 =C3=A0 15:30 -0400, jamal a =C3=A9crit :
> Eric!
>=20
> I managed to mod your program to look conceptually similar to mine
> and i reproduced the results with same test kernel from yesterday.=20
> So it is likely the issue is in using epoll vs not using any async as
> in your case.
> Results attached as well as modified program.
>=20
> Note: the key things to remember:
> rps with this program gets worse over time and different net-next
> kernels since Apr14 (look at graph i supplied). Sorry, I am really
> busy-ed out to dig any further.
>=20
> cheers,
> jamal
>=20

I am lost.

I used your program, and with RPS off, I can get at most 220.000 pps
with my "old" hardware. I dont understand how you can reach 700.000 pps
with RPS off. Or is it with your Nehalem ?



