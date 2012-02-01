From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v7, kernel version 3.2.1] Source mode for macvlan interface
Date: Wed, 1 Feb 2012 20:59:27 +0100
Message-ID: <CAGsizzJc9pJ-xsX12JNxZhFBC7VzF6QkRZMoPopK1nsVtA0AeA@mail.gmail.com>
References: <21672990.651327923923151.JavaMail.root@5-MeO-DMT.ynet.sk>
 <13688762.701327924297781.JavaMail.root@5-MeO-DMT.ynet.sk> <20120201.143455.1014458821077044311.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120201.143455.1014458821077044311.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/2/1 David Miller <davem@davemloft.net>:
> From: Stefan Gula <steweg@ynet.sk>
> Date: Mon, 30 Jan 2012 12:51:37 +0100 (CET)
>
>> V6 changes:
>> =A0- removed ability to fill the list of macaddr per link to fix the
>> =A0 =A0issue of netlink skb size. This can be added back by using se=
parate
>> =A0 =A0netlink dumper in kernel and parse inside iproute2 codes. Tho=
se codes
>> =A0 =A0are beyond my abilities so if anyone actually need that feel =
free to
>> =A0 =A0help.
>
> I'm not applying this patch until you add an appropriate way to query
> the setting, working around the link dump SKB size issue by not provi=
ding
> a way to query the information at all is not acceptable.
Ok
