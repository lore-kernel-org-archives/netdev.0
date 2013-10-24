From: =?ISO-8859-1?Q?Fran=E7ois_Cachereul?= <f.cachereul@alphalink.fr>
Subject: Re: [RFC PATCH net-next] ppp: Allow ppp device connected to an l2tp
 session to change of namespace
Date: Thu, 24 Oct 2013 15:41:59 +0200
Message-ID: <526923A7.8090108@alphalink.fr>
References: <5268F6CD.9070600@alphalink.fr> <5268FCB1.7020903@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <5268FCB1.7020903@katalix.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/2013 12:55 PM, James Chapman wrote:
> On 24/10/13 11:30, Fran=E7ois Cachereul wrote:
>> Remove NETIF_F_NETNS_LOCAL flag from ppp device in ppp_connect_chann=
el()
>> if the device is connected to a l2tp session socket.
>> Restore the flag in ppp_disconnect_channel().
>=20
> What about pppd's network namespace? Also, L2TP's tunnel socket (UDP =
or
> L2TP/IP) will be in a different namespace if the ppp interface is mov=
ed.

That's what I'm trying to achieve. I'm not using pppd and my problem is
as follow:  I need to isolate ppp devices from each other, even when
they are connected to sessions carried by the same L2TP tunnel. Also, I
need the authentication to be terminated to know the namespace in which
the ppp will be moved. For that, the process runs in a namespace with
its l2tp sockets (tunnel and session) in that same namespace and each
ppp device is moved in a specific namespace after authentication.
=20
Regards
=46ran=E7ois

