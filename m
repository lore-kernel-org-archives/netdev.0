From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 25 Jan 2012 06:53:30 +0100
Message-ID: <1327470810.14373.39.camel@edumazet-laptop>
References: <3900291.2831326843194846.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefan Gula <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3900291.2831326843194846.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 18 janvier 2012 =C3=A0 00:33 +0100, Stefan Gula a =C3=A9cri=
t :
> From: Stefan Gula <steweg@gmail.com>
>=20
> This patch is an extension for current Ethernet over GRE
> implementation, which allows user to create virtual bridge (multipoin=
t
> VPN) and forward traffic based on Ethernet MAC address information in
> it. It simulates the Bridge behavior learning mechanism, but instead
> of learning port ID from which given MAC address comes, it learns IP
> address of peer which encapsulated given packet. Multicast, Broadcast
> and unknown-multicast traffic is send over network as multicast
> encapsulated GRE packet, so one Ethernet multipoint GRE tunnel can be
> represented as one single virtual switch on logical level and be also
> represented as one multicast IPv4 address on network level.
>=20
> Signed-off-by: Stefan Gula <steweg@gmail.com>
>=20
> ---
>=20

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I guess remaining performance point is to get a refcount less
ip_route_output_gre(), aka ip_route_output_gre_noref() :)
