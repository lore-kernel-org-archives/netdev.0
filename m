From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] net: ipv4: add IPPROTO_ICMP socket kind
Date: Thu, 14 Apr 2011 09:53:11 +0800
Message-ID: <20110414015310.GC5167@verge.net.au>
References: <20110409101514.GA4262@albatros>
 <BANLkTi=ogJg_uJqsJFpnwnnr6LS+SFT3Vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vasiliy Kulikov <segoon@openwall.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>,
	Solar Designer <solar@openwall.com>,
	Kees Cook <kees.cook@canonical.com>,
	Dan Rosenberg <dan.j.rosenberg@gmail.com>,
	Eugene Teo <eugene@redhat.com>,
	Nelson Elhage <nelhage@ksplice.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Pekka Savola <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTi=ogJg_uJqsJFpnwnnr6LS+SFT3Vg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 13, 2011 at 01:29:49PM +0300, Alexey Dobriyan wrote:
> On Sat, Apr 9, 2011 at 1:15 PM, Vasiliy Kulikov <segoon@openwall.com>=
 wrote:

[snip]

> > @@ -714,8 +790,22 @@ static __net_init int ipv4_sysctl_init_net(str=
uct net *net)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0&net->ipv4.sysctl_icmp_ratemask;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0table[6].dat=
a =3D
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0&net->ipv4.sysctl_rt_cache_rebuild_count;
> > +#ifdef CONFIG_IP_PING
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 table[7].data =3D
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 &net->ipv4.sysctl_ping_group_range;
> > +#endif
>=20
> Now I understand it's not related, but next sysctl will have
> "table[8].data =3D ..." line which is off-by-one if CONFIG_IP_PING=3D=
n.

Another good reason for the code to be non-optoinal
and not to have CONFIG_IP_PING.
