From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v1, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Mon, 16 Jan 2012 15:25:32 +0100
Message-ID: <1326723932.2255.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAGsizzJTbGGpwrn-P=SUtqBW=1AN6hCTVXKp_oKHPBAoGZ4ubA@mail.gmail.com>
	 <1326719999.2255.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAGsizzJpdF5xzsEiZd5R0GD8r7pDJyz4ro=4vLBnonxfAVYg-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?=C5=A0tefan?= Gula <steweg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzJpdF5xzsEiZd5R0GD8r7pDJyz4ro=4vLBnonxfAVYg-Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 16 janvier 2012 =C3=A0 15:05 +0100, =C5=A0tefan Gula a =C3=A9c=
rit :
> D=C5=88a 16. janu=C3=A1ra 2012 14:19, Eric Dumazet <eric.dumazet@gmai=
l.com> nap=C3=ADsal/a:

> > Unfortunately you call ipgre_tap_bridge_get() from
> > ipgre_tap_bridge_get_raddr() but you dont release the refcount on
> > use_count. Leak in ipgre_tunnel_xmit()
> >
> >
> >> +__be32 ipgre_tap_bridge_get_raddr(struct ip_tunnel *tunnel,
> >> +     const unsigned char *addr)
> >> +{
> >> +     struct ipgre_tap_bridge_entry *entry;
> >> +     entry =3D ipgre_tap_bridge_get(tunnel, addr);
> >
> >        So maybe you want __ipgre_tap_bridge_get(tunnel, addr); here=
 ?
> >
> Hmmm.. I am sorry, I am maybe not that expert on C coding, as most of
> the codes were copied from linux bridge code. Can you give me a hint
> how should I change that?

I dont see in net/bridge the code you copied.

Could you give more information ?
