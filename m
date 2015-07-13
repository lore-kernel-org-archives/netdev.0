From: Akemi Yagi <amyagi@gmail.com>
Subject: Re: Linux 4.2 build error in
 net/netfilter/ipset/ip_set_hash_netnet.c
Date: Mon, 13 Jul 2015 16:13:31 +0000 (UTC)
Message-ID: <mo0o3b$g5d$1@ger.gmane.org>
References: <CAHTgTXUmreHAqPfgGEd+GJNb_OEzaCuytqBTjZsE2GDqiy3TCw@mail.gmail.com>
	<20150705153520.GA23589@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 05 Jul 2015 08:35:20 -0700, Guenter Roeck wrote:

> On Sat, Jul 04, 2015 at 12:44:36AM -0700, Vinson Lee wrote:
>> Hi.
>>=20
>> With the latest Linux 4.2-rc1, I am hitting this build error with GC=
C
>> 4.4.7 on CentOS 6.
>>=20
>>   CC      net/netfilter/ipset/ip_set_hash_netnet.o
>> net/netfilter/ipset/ip_set_hash_netnet.c: In function
>> =E2=80=98hash_netnet4_uadt=E2=80=99:
>> net/netfilter/ipset/ip_set_hash_netnet.c:163: error: unknown field
>> =E2=80=98cidr=E2=80=99 specified in initializer
>> net/netfilter/ipset/ip_set_hash_netnet.c:163: warning: missing brace=
s
>> around initializer net/netfilter/ipset/ip_set_hash_netnet.c:163:
>> warning: (near initialization for =E2=80=98e.<anonymous>.ip=E2=80=99=
)
>> net/netfilter/ipset/ip_set_hash_netnet.c: In function
>> =E2=80=98hash_netnet6_uadt=E2=80=99:
>> net/netfilter/ipset/ip_set_hash_netnet.c:388: error: unknown field
>> =E2=80=98cidr=E2=80=99 specified in initializer
>> net/netfilter/ipset/ip_set_hash_netnet.c:388: warning: missing brace=
s
>> around initializer net/netfilter/ipset/ip_set_hash_netnet.c:388:
>> warning: (near initialization for =E2=80=98e.ip[0]=E2=80=99)
>>=20
> Previously fixed with commit 1a869205c75cb ("netfilter: ipset: The
> unnamed union initialization may lead to compilation error"),
> reintroduced with commit aff227581ed1a ("netfilter: ipset: Check CIDR
> value only when attribute is given").
>=20
> Guenter

I wonder what can be done to get this issue fixed. This problem was see=
n=20
in 4.2-rc1 and now in 4.2-rc2 on RHEL-6.6.

$ gcc --version
gcc (GCC) 4.4.7 20120313 (Red Hat 4.4.7-11)

Please advise.

Akemi
