From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] netfilter: add CHECKSUM target
Date: Sun, 11 Jul 2010 16:19:28 +0300
Message-ID: <20100711131928.GB3461@redhat.com>
References: <20100708222913.GA4475@redhat.com>
 <alpine.LSU.2.01.1007091154120.7235@obet.zrqbmnf.qr>
 <20100711122708.GA3573@redhat.com>
 <AANLkTikamhUUuoQ8EjwPn9gB4zHZkeDuzpiqd4XcN3lx@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, herbert.xu@redhat.com, kvm@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikamhUUuoQ8EjwPn9gB4zHZkeDuzpiqd4XcN3lx@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 11, 2010 at 08:45:01PM +0800, Changli Gao wrote:
> On Sun, Jul 11, 2010 at 8:27 PM, Michael S. Tsirkin <mst@redhat.com> =
wrote:
> > On Fri, Jul 09, 2010 at 11:56:26AM +0200, Jan Engelhardt wrote:
> >>
> >> On Friday 2010-07-09 00:29, Michael S. Tsirkin wrote:
> >> >
> >> > include/linux/netfilter_ipv4/ipt_CHECKSUM.h | =A0 18 +++++++
> >> > net/ipv4/netfilter/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 16 ++++++
> >> > net/ipv4/netfilter/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A01 +
> >> > net/ipv4/netfilter/ipt_CHECKSUM.c =A0 =A0 =A0 =A0 =A0 | =A0 72 +=
++++++++++++++++++++++++++
> >>
> >> New modules should use xt.
> >
> > I tried moving the module to xt_CHECKSUM but now
> > =A0 =A0 =A0 =A0iptables -A POSTROUTING -t mangle -p udp --dport 68 =
-j CHECKSUM --checksum-fill
> > does not to load the module.
> > It seems that xt_request_find_target in x_tables uses the prefix 'i=
p' for a module.
> > What am I missing?
> >
>=20
> You should add MODULE_ALIAS clause, i.e.
>=20
> MODULE_ALIAS("ipt_CHECKSUM");

This worked, thanks!

> --=20
> Regards,
> Changli Gao(xiaosuo@gmail.com)
