From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Tue, 11 Jan 2011 22:46:26 +0100
Message-ID: <1294782386.3447.21.camel@edumazet-laptop>
References: <1294779020.16410.2.camel@wall-e>
	 <20110111.125254.133402589.davem@davemloft.net>
	 <1294780480.17388.2.camel@wall-e>
	 <20110111.131953.180400101.davem@davemloft.net>
	 <1294782117.17531.18.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, jj@chaosbits.net, daniel.baluta@gmail.com,
	jochen@jochen.org, hagen@jauu.net, torvalds@linux-foundation.org,
	pavel@ucw.cz
To: Stefani Seibold <stefani@seibold.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294782117.17531.18.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 11 janvier 2011 =C3=A0 22:41 +0100, Stefani Seibold a =C3=A9cr=
it :

> Second, the design is may in your opinion poor. I like it. What is
> really poor is the kernel_...() socket functions, which are only simp=
le
> wrapper of the system calls without any performance improvement, skb
> support and memory saving.
>=20

The only thing you want is to have a callback to your own code to
deliver an decapsulated skb to your state machine.

Take a look at other layers on top of UDP

(L2TP comes to mind)
