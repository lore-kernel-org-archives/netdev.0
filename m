From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Tue, 11 Jan 2011 23:23:29 +0100
Message-ID: <1294784609.18562.4.camel@wall-e>
References: <1294779020.16410.2.camel@wall-e>
	 <20110111.125254.133402589.davem@davemloft.net>
	 <1294780480.17388.2.camel@wall-e>
	 <20110111.131953.180400101.davem@davemloft.net>
	 <1294782117.17531.18.camel@wall-e>
	 <1294782386.3447.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, jj@chaosbits.net, daniel.baluta@gmail.com,
	jochen@jochen.org, hagen@jauu.net, torvalds@linux-foundation.org,
	pavel@ucw.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294782386.3447.21.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, den 11.01.2011, 22:46 +0100 schrieb Eric Dumazet:
> Le mardi 11 janvier 2011 =E0 22:41 +0100, Stefani Seibold a =E9crit :
>=20
> > Second, the design is may in your opinion poor. I like it. What is
> > really poor is the kernel_...() socket functions, which are only si=
mple
> > wrapper of the system calls without any performance improvement, sk=
b
> > support and memory saving.
> >=20
>=20
> The only thing you want is to have a callback to your own code to
> deliver an decapsulated skb to your state machine.
>=20
> Take a look at other layers on top of UDP
>=20
> (L2TP comes to mind)
>=20

I have looked on it. And it will not work since UDPCP is UDP. And so
IPPROTO_UDP (17) is still handled by the UDP handler.

Despite this it will also make no sense to rewrite the whole UDP socket
layer.

The only thing i have found with comes near to my requirements is the
rxrpc module, but i see no real different to my solution.
