From: Cong Wang <cwang@twopensource.com>
Subject: Re: Linux 4.2 build error in net/netfilter/ipset/ip_set_hash_netnet.c
Date: Mon, 13 Jul 2015 11:17:57 -0700
Message-ID: <CAHA+R7PkkgSrzj2Kf5Y3hWe=UmvcUodx=UnyL_gJM6uT7DMqJA@mail.gmail.com>
References: <CAHTgTXUmreHAqPfgGEd+GJNb_OEzaCuytqBTjZsE2GDqiy3TCw@mail.gmail.com>
	<20150705153520.GA23589@roeck-us.net>
	<mo0o3b$g5d$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Sergey Popovich <popovich_sergei@mail.ua>
To: Akemi Yagi <amyagi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <mo0o3b$g5d$1@ger.gmane.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 13, 2015 at 9:13 AM, Akemi Yagi <amyagi@gmail.com> wrote:
> On Sun, 05 Jul 2015 08:35:20 -0700, Guenter Roeck wrote:
>
>> On Sat, Jul 04, 2015 at 12:44:36AM -0700, Vinson Lee wrote:
>>> Hi.
>>>
>>> With the latest Linux 4.2-rc1, I am hitting this build error with G=
CC
>>> 4.4.7 on CentOS 6.
>>>
>>>   CC      net/netfilter/ipset/ip_set_hash_netnet.o
>>> net/netfilter/ipset/ip_set_hash_netnet.c: In function
>>> =E2=80=98hash_netnet4_uadt=E2=80=99:
>>> net/netfilter/ipset/ip_set_hash_netnet.c:163: error: unknown field
>>> =E2=80=98cidr=E2=80=99 specified in initializer
>>> net/netfilter/ipset/ip_set_hash_netnet.c:163: warning: missing brac=
es
>>> around initializer net/netfilter/ipset/ip_set_hash_netnet.c:163:
>>> warning: (near initialization for =E2=80=98e.<anonymous>.ip=E2=80=99=
)
>>> net/netfilter/ipset/ip_set_hash_netnet.c: In function
>>> =E2=80=98hash_netnet6_uadt=E2=80=99:
>>> net/netfilter/ipset/ip_set_hash_netnet.c:388: error: unknown field
>>> =E2=80=98cidr=E2=80=99 specified in initializer
>>> net/netfilter/ipset/ip_set_hash_netnet.c:388: warning: missing brac=
es
>>> around initializer net/netfilter/ipset/ip_set_hash_netnet.c:388:
>>> warning: (near initialization for =E2=80=98e.ip[0]=E2=80=99)
>>>
>> Previously fixed with commit 1a869205c75cb ("netfilter: ipset: The
>> unnamed union initialization may lead to compilation error"),
>> reintroduced with commit aff227581ed1a ("netfilter: ipset: Check CID=
R
>> value only when attribute is given").
>>
>> Guenter
>
> I wonder what can be done to get this issue fixed. This problem was s=
een
> in 4.2-rc1 and now in 4.2-rc2 on RHEL-6.6.
>

Just revert the initializer piece.
