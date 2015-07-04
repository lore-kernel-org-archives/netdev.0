From: Vinson Lee <vlee@twopensource.com>
Subject: Linux 4.2 build error in net/netfilter/ipset/ip_set_hash_netnet.c
Date: Sat, 4 Jul 2015 00:44:36 -0700
Message-ID: <CAHTgTXUmreHAqPfgGEd+GJNb_OEzaCuytqBTjZsE2GDqiy3TCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Sergey Popovich <popovich_sergei@mail.ua>,
	Anton Danilov <littlesmilingcloud@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

With the latest Linux 4.2-rc1, I am hitting this build error with GCC
4.4.7 on CentOS 6.

  CC      net/netfilter/ipset/ip_set_hash_netnet.o
net/netfilter/ipset/ip_set_hash_netnet.c: In function =E2=80=98hash_net=
net4_uadt=E2=80=99:
net/netfilter/ipset/ip_set_hash_netnet.c:163: error: unknown field
=E2=80=98cidr=E2=80=99 specified in initializer
net/netfilter/ipset/ip_set_hash_netnet.c:163: warning: missing braces
around initializer
net/netfilter/ipset/ip_set_hash_netnet.c:163: warning: (near
initialization for =E2=80=98e.<anonymous>.ip=E2=80=99)
net/netfilter/ipset/ip_set_hash_netnet.c: In function =E2=80=98hash_net=
net6_uadt=E2=80=99:
net/netfilter/ipset/ip_set_hash_netnet.c:388: error: unknown field
=E2=80=98cidr=E2=80=99 specified in initializer
net/netfilter/ipset/ip_set_hash_netnet.c:388: warning: missing braces
around initializer
net/netfilter/ipset/ip_set_hash_netnet.c:388: warning: (near
initialization for =E2=80=98e.ip[0]=E2=80=99)

Cheers,
Vinson
