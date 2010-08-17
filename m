From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Tue, 17 Aug 2010 19:13:47 +0200
Message-ID: <1282065227.2448.116.camel@edumazet-laptop>
References: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se>
	 <1281953960.2524.23.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se>
	 <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se>
	 <1282024802.2487.687.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se>
	 <1282050920.2448.47.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se>
	 <1282055659.2448.58.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008171737260.21857@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1008171737260.21857@red.crap.retrofitta.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 17 ao=C3=BBt 2010 =C3=A0 17:58 +0200, Thomas Habets a =C3=A9cr=
it :

> If you expected more bits set in "filters" with allmulti than without=
 it,=20
> that doesn't seem to be the case.


Nope, the patch displays mc list and filters bits only if not
promiscuous and not allmulti (normal ethernet mode)

If promiscuous -> a special PROMISC bit is selected on NIC (no display)
If allmulti -> all 128 bits are set (but not displayed in my patch)

I wanted to make sure the correct list of mc addrs is handled on your
machine. It seems to be the case, so there might be a hardware problem
with the multicast rx on this particular NIC
