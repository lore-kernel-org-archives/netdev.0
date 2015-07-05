From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: Linux 4.2 build error in net/netfilter/ipset/ip_set_hash_netnet.c
Date: Sun, 5 Jul 2015 08:35:20 -0700
Message-ID: <20150705153520.GA23589@roeck-us.net>
References: <CAHTgTXUmreHAqPfgGEd+GJNb_OEzaCuytqBTjZsE2GDqiy3TCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Sergey Popovich <popovich_sergei@mail.ua>,
	Anton Danilov <littlesmilingcloud@gmail.com>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Vinson Lee <vlee@twopensource.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHTgTXUmreHAqPfgGEd+GJNb_OEzaCuytqBTjZsE2GDqiy3TCw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 04, 2015 at 12:44:36AM -0700, Vinson Lee wrote:
> Hi.
>=20
> With the latest Linux 4.2-rc1, I am hitting this build error with GCC
> 4.4.7 on CentOS 6.
>=20
>   CC      net/netfilter/ipset/ip_set_hash_netnet.o
> net/netfilter/ipset/ip_set_hash_netnet.c: In function =E2=80=98hash_n=
etnet4_uadt=E2=80=99:
> net/netfilter/ipset/ip_set_hash_netnet.c:163: error: unknown field
> =E2=80=98cidr=E2=80=99 specified in initializer
> net/netfilter/ipset/ip_set_hash_netnet.c:163: warning: missing braces
> around initializer
> net/netfilter/ipset/ip_set_hash_netnet.c:163: warning: (near
> initialization for =E2=80=98e.<anonymous>.ip=E2=80=99)
> net/netfilter/ipset/ip_set_hash_netnet.c: In function =E2=80=98hash_n=
etnet6_uadt=E2=80=99:
> net/netfilter/ipset/ip_set_hash_netnet.c:388: error: unknown field
> =E2=80=98cidr=E2=80=99 specified in initializer
> net/netfilter/ipset/ip_set_hash_netnet.c:388: warning: missing braces
> around initializer
> net/netfilter/ipset/ip_set_hash_netnet.c:388: warning: (near
> initialization for =E2=80=98e.ip[0]=E2=80=99)
>=20
Previously fixed with commit 1a869205c75cb ("netfilter: ipset: The unna=
med union
initialization may lead to compilation error"), reintroduced with commi=
t
aff227581ed1a ("netfilter: ipset: Check CIDR value only when attribute =
is given").

Guenter
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
