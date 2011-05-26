From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.11
Date: Thu, 26 May 2011 20:28:57 +0200
Message-ID: <1306434537.2543.4.camel@edumazet-laptop>
References: <4DDE857E.40807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, NetDev <netdev@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4DDE857E.40807@trash.net>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 26 mai 2011 =C3=A0 18:53 +0200, Patrick McHardy a =C3=A9crit :
> The netfilter coreteam presents:
>=20
>     iptables version 1.4.10
>=20
> the iptables release for the 2.6.39 kernels. Due to some mistakes
> on my side we didn't have a release for longer than expected, so
> this contains a rather large number of changes.
>=20
> Changes include:
>=20

=2E..
> - a new iptables option "-C" to check for existance of a rules

Nice, but this still loads modules...

# lsmod | grep ipta
# ./iptables -C INPUT -p tcp=20
iptables: Bad rule (does a matching rule exist in that chain?).
# lsmod | grep ipta
iptable_filter          1730  0=20
ip_tables              15958  1 iptable_filter
x_tables               22998  3 iptable_filter,ip_tables,xt_tcpudp




