From: hoerdt@clarinet.u-strasbg.fr
Subject: (usagi-users 03611) Re: IPv6 setsockopt software MTU patch
Date: Sun, 19 Feb 2006 15:54:13 +0100
Message-ID: <20060219145413.GD16304@clarinet.u-strasbg.fr>
References: <43F5A7B2.90803@6wind.com> <20060217.215101.09874309.yoshfuji@linux-ipv6.org> <20060219134709.GC16304@clarinet.u-strasbg.fr> <20060219.231344.11160682.yoshfuji@linux-ipv6.org>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, netdev@vger.kernel.org, olivier.matz@6wind.com,
        yoshfuji@linux-ipv6.org
Return-path: <usagi-users-admin@linux-ipv6.org>
To: usagi-users@linux-ipv6.org
In-Reply-To: <20060219.231344.11160682.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Yes, Hugo Santos suggested me to use the minimum of both, the new
patch is available there :

http://clarinet.u-strasbg.fr/~hoerdt/ip6_output.c.softfrag.patch2

Thanks,

Hoerdt Micka=EBl


On Sun, Feb 19, 2006 at 11:13:44PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@=
 wrote:
> In article <20060219134709.GC16304@clarinet.u-strasbg.fr> (at Sun, 19 F=
eb 2006 14:47:09 +0100), hoerdt@clarinet.u-strasbg.fr says:
>=20
> > The fix is very simple, it only grab the value of frag_size and
> > use it in ip6_fragment file, could you please review the patch which
> > fix that problem at :
> >=20
> > http://clarinet.u-strasbg.fr/~hoerdt/ip6_output.c.softfrag.patch
>=20
> Thanks for the patch.
> I think even we have np->frag_size, we should consider dst_mtu(&rt->u.d=
st)
> as well. No?
>=20
> --yoshfuji
>=20
>=20
