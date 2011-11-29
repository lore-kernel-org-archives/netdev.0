From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC PATCH 00/18] netfilter: IPv6 NAT
Date: Tue, 29 Nov 2011 23:21:11 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1111292306460.18953@frira.zrqbmnf.qr>
References: <CAF9AA63.1622%ulrich.weber@sophos.com> <a2407c3b6405bd682cedad6db82cf225@treenet.co.nz> <4ED4A399.6090709@sophos.com> <alpine.LNX.2.01.1111291255200.20965@frira.zrqbmnf.qr> <4ED550E7.1090609@ans.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Weber <ulrich.weber@sophos.com>,
	Amos Jeffries <squid3@treenet.co.nz>,
	"sclark46@earthlink.net" <sclark46@earthlink.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Krzysztof_Ol=C4=99dzki?= <ole@ans.pl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4ED550E7.1090609@ans.pl>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2011-11-29 22:38, Krzysztof Ol=C4=99dzki wrote:
>>
>> Same network prefix, some cookies, or a login form. Blam, identified=
,
>> or at least (Almost-)Uniquely Identified Visitor tagging.
>
> But without NAT you have pretty big chance to have the same IPv6 *suf=
fix*
> everywhere, based on you MAC address.

Everywhere? No, one small village of indomitable Gauls.^^^^^^^^W

$ ip a
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP q=
len 1000
    link/ether 00:0d:93:9e:08:78 brd ff:ff:ff:ff:ff:ff
    inet6 2001:638:600:8810:d070:3a36:464e:b3db/64 scope global tempora=
ry dynamic=20
       valid_lft 583732sec preferred_lft 64732sec
    inet6 2001:638:600:8810:d9f5:18f5:4fc1:9a20/64 scope global tempora=
ry deprecated dynamic=20
       valid_lft 497938sec preferred_lft 0sec
    [...]

Same suffix? Certainly not with contemporary configurations (and
Linux did this quite on its own there). In fact, now that there is
almost v6-NAT in the kernel, I fear that users who are blinded by NAT
now make the problem worse by actually feeding perfectly good Privacy
Extension Addresses into a n:1-configured SNAT/MASQUERADE target
instead of a NETMAP.

> In your Home, your Work, in a Cafe or in
> a hotel during your vacations in Portugal.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
