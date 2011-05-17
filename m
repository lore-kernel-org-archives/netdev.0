From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in
 netdevice
Date: Tue, 17 May 2011 15:28:38 -0700
Message-ID: <1305671318.10756.49.camel@localhost.localdomain>
References: <1305574128.3456.23.camel@localhost.localdomain>
	 <1305574518.2885.25.camel@bwh-desktop>
	 <1305574680.3456.33.camel@localhost.localdomain>
	 <1305575253.2885.28.camel@bwh-desktop> <20110516211459.GE18148@redhat.com>
	 <1305588738.3456.65.camel@localhost.localdomain>
	 <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-05-17 at 23:48 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> 2011/5/17 Shirley Ma <mashirle@us.ibm.com>:
> > Hello Michael,
> >
> > Looks like to use a new flag requires more time/work. I am thinking
> > whether we can just use HIGHDMA flag to enable zero-copy in macvtap
> to
> > avoid the new flag for now since mavctap uses real NICs as lower
> device?
>=20
> Is there any other restriction besides requiring driver to not recycl=
e
> the skb? Are there any drivers that recycle TX skbs?=20

Not more other restrictions, skb clone is OK. pskb_expand_head() looks
OK to me from code review.

Currently there is no drivers recycle TX skbs.

Thanks
Shirley

